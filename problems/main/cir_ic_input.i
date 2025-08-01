# input file.
# Define mesh. 2-D system, simulation size 200*80.
[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 100
  xmax = 200
  ny = 40
  ymin = -40
  ymax = 40
  uniform_refine = 3
[]
# variables. w: chemical potential, eta: order parameter, pot: applied overpotential.
[Variables]
  [w]
  []
  [eta]
  []
  [pot]
  []
[]
# Initial conditions.
[ICs]
  [eta]
    variable = eta
    type = SmoothCircleIC
    int_width = 2
    x1 = 0
    y1 = 0
    radius = 10
    outvalue = 0
    invalue = 1
  []
  [w]
    variable = w
    type = ConstantIC
    value = 0
  []
  [pot]
    variable = pot
    type = SmoothCircleIC
    int_width = 2
    x1 = 0
    y1 = 0
    radius = 10
    outvalue = 0
    invalue = -0.45
  []
[]
# Boundary conditions.
[BCs]
[bottom_eta]
    type = NeumannBC
    variable = 'eta'
    boundary = 'bottom'
    value = 0
  []
  [top_eta]
    type = NeumannBC
    variable = 'eta'
    boundary = 'top'
    value = 0
  []
  [left_eta]
    type = NeumannBC
    variable = 'eta'
    boundary = 'left'
    value = 0
  []
  [right_eta]
    type = NeumannBC
    variable = 'eta'
    boundary = 'right'
    value = 0
  []
  [bottom_w]
    type = NeumannBC
    variable = 'w'
    boundary = 'bottom'
    value = 0
  []
  [top_w]
    type = NeumannBC
    variable = 'w'
    boundary = 'top'
    value = 0.0
  []
  [left_w]
    type = NeumannBC
    variable = 'w'
    boundary = 'left'
    value = 0
  []
  [right_w]
    type = DirichletBC
    variable = 'w'
    boundary = 'right'
    value = 0.0
  []
  [left_pot]
    type = DirichletBC
    variable = 'pot'
    boundary = 'left'
    value = -0.45
  []
  [right_pot]
    type = DirichletBC
    variable = 'pot'
    boundary = 'right'
    value = 0
  []
[]

[Kernels]
  # First part of equation 3 in main text . chi*dw/dt
  [w_dot]
    type = SusceptibilityTimeDerivative
    variable = w
    f_name = chi
    coupled_variables = 'w'
  []
  # Intrinsic diffusion part of equation 3 in main text.
  [Diffusion1]
    type = MatDiffusion
    variable = w
    diffusivity = D
  []
  # Migration.
  [Diffusion2]
    type = Migration
    variable = w
    cv = eta
    Q_name = 0.
    QM_name = DN
    cp = pot
  []
  # Coupling between w and eta.
  [coupled_etadot]
    type = CoupledSusceptibilityTimeDerivative
    variable = w
    v = eta
    f_name = ft
    coupled_variables = 'eta'
  []
  # Conduction, left handside of equation 4 in main text.
  [Cond]
    type = Conduction
    variable = pot
    cp = eta
    cv = w
    Q_name = Le1
    QM_name = 0.
  []
  # Source term for Equation 4 in main text.
  [coupled_pos]
    type = CoupledSusceptibilityTimeDerivative
    variable = pot
    v = eta
    f_name = ft2
    coupled_variables = 'eta'
  []
  # Bulter-volmer equation, right hand side of Equation 1 in main text.
  [BV]
    type = Kinetics
    variable = eta
    f_name = G
    cp = pot
    cv = eta
  []
  # Driving force from switching barrier, right hand side of Equation 1 in main text.
  [AC_bulk]
    type = AllenCahn
    variable = eta
    f_name = FF
  []
  # interfacial energy
  [AC_int]
    type = ACInterface
    variable = eta
  []
  [Noiseeta]
    type = LangevinNoise
    variable = eta
    amplitude = 0.04
  []
  # deta/dt
  [e_dot]
    type = TimeDerivative
    variable = eta
  []
[]

[Materials]

  [constants]
    type = GenericConstantMaterial
    # kappa_op: gradient coefficient;  M0:diffucion coefficient of Li+ in electrolyte
    #  S1, S2 conductivity of electrode and electrolyte; L: kinetic coefficient; Ls: electrochemical kinetic coefficient; B: Barrier height;
    #  es, el: difference in the chemical potential of lithium and neutral components on the electrode/electrolyte phase at initial equilibrium state;
    # us, ul: free energy density of the electrode/electrolyte phases. Defined in Ref. 20 and 26 of the main text; A: prefactor; AA: nF/(R*T);
    # dv is the ratio of site density for the electrode/electrolyte phases; ft2: normalized used in Equation 4.

    prop_names = 'kappa_op  M0     S1    S2     L    Ls       B   es       el    A     ul    us    AA  dv   ft2'
    prop_values = '0.3   317.9   1000000 1.19   6.25   0.001  2.4  -13.8  2.631   1.0   0.0695 13.8   38.69 5.5 0.0074'
  []
  # grand potential of electrolyte phase
  [liquid_GrandPotential]
    type = DerivativeParsedMaterial
    expression = 'ul-A*log(1+exp((w-el)/A))'
    coupled_variables = 'w'
    property_name = f1
    material_property_names = 'A ul el'
  []
  # grand potential of electrode phase
  [solid_GrandPotential]
    type = DerivativeParsedMaterial
    expression = 'us-A*log(1+exp((w-es)/A))'
    coupled_variables = 'w'
    property_name = f2
    material_property_names = 'A us es'
  []
  #interpolation function h
  [switching_function]
    type = SwitchingFunctionMaterial
    eta = 'eta'
    h_order = HIGH
  []
  # Barrier function g
  [barrier_function]
    type = BarrierFunctionMaterial
    eta = eta
  []
  [total_GrandPotential]
    type = DerivativeTwoPhaseMaterial
    coupled_variables = 'w'
    eta = eta
    fa_name = f1
    fb_name = f2
    derivative_order = 2
    W = 2.4
  []
  # Coupling between eta and w
  [coupled_eta_function]
    type = DerivativeParsedMaterial
    expression = '-(cs*dv-cl)*dh' # in this code cs=-cs h=eta dh=1
    coupled_variables = ' w eta'
    property_name = ft
    material_property_names = 'dh:=D[h,eta] h dv cs:=D[f2,w] cl:=D[f1,w]'
    derivative_order = 1
  []
  [susceptibility]
    type = DerivativeParsedMaterial
    expression = '-d2F1*(1-h)-d2F2*h*dv'
    coupled_variables = 'w'
    property_name = chi
    derivative_order = 1
    material_property_names = 'h dv d2F1:=D[f1,w,w] d2F2:=D[f2,w,w]'
  []
  # Mobility defined by D*c/(R*T), whereR*T is normalized by the chemical potential
  # M0*(1-h) is the effective diffusion coefficient; cl*(1-h) is the ion concentration
  [Mobility_coefficient]
    type = DerivativeParsedMaterial
    expression = '-M0*(1-h)*cl*(1-h)' #c is -c
    property_name = D
    coupled_variables = 'eta w'
    derivative_order = 1
    material_property_names = ' M0 cl:=D[f1,w] h'
  []
  # Energy of the barrier
  [Free]
    type = DerivativeParsedMaterial
    property_name = FF
    material_property_names = 'B'
    coupled_variables = 'eta'
    expression = 'B*eta*eta*(1-eta)*(1-eta)'
    derivative_order = 1
  []
  # Migration coefficient.
  [Migration_coefficient]
    type = DerivativeParsedMaterial
    expression = '-cl*(1-h)*AA*M0*(1-h)'
    coupled_variables = 'eta w'
    property_name = DN
    derivative_order = 1
    material_property_names = 'M0 AA cl:=D[f1,w] h'
  []
  [Bultervolmer]
    type = DerivativeParsedMaterial
    expression = 'Ls*(exp(pot*AA/2.)+14.89*cl*(1-h)*exp(-pot*AA/2.))*dh'
    coupled_variables = 'pot eta w'
    property_name = G
    derivative_order = 1
    material_property_names = 'Ls dh:=D[h,eta] h cl:=D[f1,w] AA'
    outputs = exodus
  []
  # output the ion concentration
  [concentration]
    type = ParsedMaterial
    property_name = c
    coupled_variables = 'eta w'
    material_property_names = 'h dFl:=D[f1,w]'
    expression = '-dFl*(1-h)'
    outputs = exodus
  []
  # Effective conductivity
  [Le1]
    type = DerivativeParsedMaterial
    property_name = Le1
    coupled_variables = 'eta'
    material_property_names = 'S1 S2 h'
    expression = 'S1*h+S2*(1-h)'
    derivative_order = 1
  []
[]
[GlobalParams]
  enable_jit = false # Disable JIT
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
    petsc_options_iname = '-pc_type -ksp_grmres_restart -sub_ksp_type -sub_pc_type -pc_asm_overlap -pc_factor_levels'
    petsc_options_value = 'asm      121                  gmres       ilu           8                2'
  []
[]

[Executioner]
  type = Transient
  scheme = bdf2
  #solve_type =Newton
  solve_type = PJFNK
  l_max_its = 50
  l_tol = 1e-4
  nl_max_its = 20
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  end_time = 400
  [./TimeStepper]
    type = IterationAdaptiveDT
    optimal_iterations = 8
    iteration_window = 2
    dt = 0.0003
    growth_factor = 1.2
    cutback_factor = 0.8
  [../]
  [./Adaptivity]
    initial_adaptivity = 2 # Number of times mesh is adapted to initial condition
    refine_fraction = 0.4 # Fraction of high error that will be refined
    coarsen_fraction = 0.2 # Fraction of low error that will coarsened
    max_h_level = 3 # Max number of refinements used, starting from initial mesh (before uniform refinement)
    weight_names = 'eta w pot'
    weight_values = '1 0.5 0.5'
  [../]
[]

[Outputs]
  exodus = true
  csv = true
  perf_graph = true
  checkpoint = true
  execute_on = 'TIMESTEP_END'
  [other] # creates input_other.e output every 30 timestep
    type = Exodus
    time_step_interval = 3
  []
[]
