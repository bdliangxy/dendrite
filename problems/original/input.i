# input file.
# Define mesh. 2-D system, simulation size 200*200.
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 200
  xmax =200
  ny=200
  ymax=200
[]
# variables. w: chemical potential, eta: order parameter, pot: applied overpotential.
[Variables]
  [./w]
  [../]
  [./eta]
  [../]
  [./pot]
  [../]
[]
# Creating functions for initial conditions.
[Functions]
[./ic_func_eta]
  type = ParsedFunction
  value = 0.5*(1.0-1.0*tanh((x-20)*2))
[../]
[./ic_func_c]
  type = ParsedFunction
  value = 0
[../]
  [./ic_func_pot]
  type = ParsedFunction
  value = -0.225*(1.0-tanh((x-20)*2))
[../]
[]
# Initial conditions.
[ICs]
  [./eta]
    variable = eta
    type = FunctionIC
    function = ic_func_eta
  [../]
  [./w]
    variable = w
     type = FunctionIC
     function = ic_func_c
  [../]
  [./pot]
    variable = pot
    type = FunctionIC
    function = ic_func_pot
  [../]
[]
# Boundary conditions.
[BCs]
[./bottom_eta]
  type = NeumannBC
  variable = 'eta'
  boundary = 'bottom'
  value = 0
[../]
[./top_eta]
  type = NeumannBC
  variable = 'eta'
  boundary = 'top'
  value = 0
[../]
[./left_eta]
  type = DirichletBC
  variable = 'eta'
  boundary = 'left'
  value = 1
[../]
[./right_eta]
  type = DirichletBC
  variable = 'eta'
  boundary = 'right'
  value = 0
[../]
 [./bottom_w]
  type = NeumannBC
  variable = 'w'
  boundary = 'bottom'
  value = 0
[../]
[./top_w]
  type = NeumannBC
  variable = 'w'
  boundary = 'top'
  value = 0.0
[../]
 [./left_w]
  type = NeumannBC
  variable = 'w'
  boundary = 'left'
  value = 0
[../]
[./right_w]
  type = DirichletBC
  variable = 'w'
  boundary = 'right'
  value = 0.0
[../]
  [./left_pot]
  type = DirichletBC
  variable = 'pot'
  boundary = 'left'
  value = -0.45
[../]
[./right_pot]
  type = DirichletBC
  variable = 'pot'
  boundary = 'right'
  value = 0
[../]
  []

[Kernels]
# First part of equation 3 in main text . chi*dw/dt
  [./w_dot]
    type = SusceptibilityTimeDerivative
    variable = w
    f_name = chi
    args = 'w'
  [../]
  # Intrinsic diffusion part of equation 3 in main text.
   [./Diffusion1]
    type = MatDiffusion
    variable=w
    D_name=D
   [../]
   # Migration.
  [./Diffusion2]
    type = Migration
    variable = w
    cv=eta
    Q_name = 0.
    QM_name = DN
    cp=pot
  [../]
  # Coupling between w and eta.
  [./coupled_etadot]
    type = CoupledSusceptibilityTimeDerivative
    variable = w
    v = eta
    f_name = ft
    args = 'eta'
  [../]
  # Conduction, left handside of equation 4 in main text.
 [./Cond]
   type = Conduction
   variable = pot
   cp=eta
   cv =w
   Q_name = Le1
   QM_name=0.
  [../]
# Source term for Equation 4 in main text.
 [./coupled_pos]
    type = CoupledSusceptibilityTimeDerivative
    variable = pot
    v = eta
    f_name = ft2
    args = 'eta'
  [../]
  # Bulter-volmer equation, right hand side of Equation 1 in main text.
  [./BV]
    type = Kinetics
    variable = eta
    f_name = G
    cp=pot
    cv=eta
  [../]
  # Driving force from switching barrier, right hand side of Equation 1 in main text.
  [./AC_bulk]
    type = AllenCahn
    variable = eta
    f_name = FF
  [../]
  # interfacial energy
  [./AC_int]
    type = ACInterface
    variable = eta
  [../]
 [./Noiseeta]
    type = LangevinNoise
    variable = eta
    amplitude=0.04
  [../]
# deta/dt
  [./e_dot]
    type = TimeDerivative
    variable = eta
  [../]
[]

[Materials]

[./constants]
  type = GenericConstantMaterial
# kappa_op: gradient coefficient;  M0:diffucion coefficient of Li+ in electrolyte
#  S1, S2 conductivity of electrode and electrolyte; L: kinetic coefficient; Ls: electrochemical kinetic coefficient; B: Barrier height;
#  es, el: difference in the chemical potential of lithium and neutral components on the electrode/electrolyte phase at initial equilibrium state;
# us, ul: free energy density of the electrode/electrolyte phases. Defined in Ref. 20 and 26 of the main text; A: prefactor; AA: nF/(R*T);
# dv is the ratio of site density for the electrode/electrolyte phases; ft2: normalized used in Equation 4.

  prop_names  = 'kappa_op  M0     S1    S2     L    Ls       B   es       el    A     ul    us    AA  dv   ft2'
  prop_values = '0.3   317.9   1000000 1.19   6.25   0.001  2.4  -13.8  2.631   1.0   0.0695 13.8   38.69 5.5 0.0074'
[../]
# grand potential of electrolyte phase
  [./liquid_GrandPotential]
    type = DerivativeParsedMaterial
    function = 'ul-A*log(1+exp((w-el)/A))'
    args = 'w'
    f_name = f1
    material_property_names = 'A ul el'
  [../]
  # grand potential of electrode phase
  [./solid_GrandPotential]
    type = DerivativeParsedMaterial
    function = 'us-A*log(1+exp((w-es)/A))'
    args = 'w'
    f_name = f2
    material_property_names = 'A us es'
  [../]
  #interpolation function h
  [./switching_function]
    type = SwitchingFunctionMaterial
    eta ='eta'
    h_order = HIGH
  [../]
  # Barrier function g
  [./barrier_function]
    type = BarrierFunctionMaterial
    eta = eta
  [../]
  [./total_GrandPotential]
    type = DerivativeTwoPhaseMaterial
    args = 'w'
    eta = eta
    fa_name = f1
    fb_name = f2
    derivative_order = 2
    W = 2.4
  [../]
 # Coupling between eta and w
  [./coupled_eta_function]
    type = DerivativeParsedMaterial
    function = '-(cs*dv-cl)*dh'  # in this code cs=-cs h=eta dh=1
    args = ' w eta'
    f_name = ft
    material_property_names = 'dh:=D[h,eta] h dv cs:=D[f2,w] cl:=D[f1,w]'
    derivative_order = 1
  [../]
  [./susceptibility]
      type = DerivativeParsedMaterial
      function = '-d2F1*(1-h)-d2F2*h*dv'
      args = 'w'
      f_name = chi
      derivative_order = 1
      material_property_names = 'h dv d2F1:=D[f1,w,w] d2F2:=D[f2,w,w]'
    [../]
    # Mobility defined by D*c/(R*T), whereR*T is normalized by the chemical potential
    # M0*(1-h) is the effective diffusion coefficient; cl*(1-h) is the ion concentration
   [./Mobility coefficient]
    type = DerivativeParsedMaterial
    function = '-M0*(1-h)*cl*(1-h)'  #c is -c
    f_name = D
     args = 'eta w'
    derivative_order = 1
    material_property_names = ' M0 cl:=D[f1,w] h'
  [../]
   # Energy of the barrier
   [./Free]
    type = DerivativeParsedMaterial
    f_name = FF
    material_property_names = 'B'
    args='eta'
    function = 'B*eta*eta*(1-eta)*(1-eta)'
    derivative_order = 1
  [../]
  # Migration coefficient.
  [./Migration coefficient]
    type = DerivativeParsedMaterial
    function = '-cl*(1-h)*AA*M0*(1-h)'
    args = 'eta w'
    f_name = DN
    derivative_order = 1
    material_property_names = 'M0 AA cl:=D[f1,w] h'
  [../]
    [./Bultervolmer]
        type = DerivativeParsedMaterial
        function = 'Ls*(exp(pot*AA/2.)+14.89*cl*(1-h)*exp(-pot*AA/2.))*dh'
        args = 'pot eta w'
        f_name = G
       derivative_order = 1
        material_property_names = 'Ls dh:=D[h,eta] h cl:=D[f1,w] AA'
        outputs = exodus
      [../]
 # output the ion concentration
  [./concentration]
    type = ParsedMaterial
    f_name = c
    args='eta w'
    material_property_names = 'h dFl:=D[f1,w]'
    function = '-dFl*(1-h)'
   outputs = exodus
  [../]
  # Effective conductivity
  [./Le1]
  type = DerivativeParsedMaterial
  f_name = Le1
  args = 'eta'
  material_property_names = 'S1 S2 h'
  function = 'S1*h+S2*(1-h)'
   derivative_order = 1
[../]
[]
[GlobalParams]
  enable_jit = false           # Disable JIT
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap'
    petsc_options_value = 'asm      121                  preonly       lu           8'
  [../]
[]

[Executioner]
  type = Transient
  scheme = bdf2
  #solve_type =Newton
  l_max_its = 50
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
    dt=0.02
    end_time = 400
[]

[Outputs]
  exodus = true
  csv = true
  execute_on = 'TIMESTEP_END'
  [./other]        # creates input_other.e output every 30 timestep
     type = Exodus
     interval = 30
  [../]
[]
