/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#include "Migration.h"

registerMooseObject("DendriteApp", Migration);

/*template <>
InputParameters
validParams<Migration>()*/
InputParameters
Migration::validParams()
{
  // InputParameters params = validParams<Kernel>();
  InputParameters params = DerivativeMaterialInterface<Kernel>::validParams();
  params.addClassDescription("Add in Migration,subroutine for electrochemical Migration equation "
                             "-[delQdel(cv)+delQNdel(cp)]");
  params.addParam<MaterialPropertyName>("Q_name", "Before coupled variables, not used here");
  params.addParam<MaterialPropertyName>("QM_name", "Migration mobility");
  params.addRequiredCoupledVar("cp", "applied potential");
  params.addRequiredCoupledVar("cv", "coupled variable");
  return params;
}

Migration::Migration(const InputParameters & parameters)
  : DerivativeMaterialInterface<Kernel>(parameters),
    _cp_var(coupled("cp")),
    _cp(coupledValue("cp")),
    _cv_var(coupled("cv")),
    _cv(coupledValue("cv")),
    _grad_cp(coupledGradient("cp")),
    _grad_cv(coupledGradient("cv")),
    _Q(getMaterialProperty<Real>("Q_name")),
    _QM(getMaterialProperty<Real>("QM_name")),
    _dQ(getMaterialPropertyDerivative<Real>("Q_name", _var.name())),
    _dQv(getMaterialPropertyDerivative<Real>("Q_name", getVar("cv", 0)->name())),
    _dQMv(getMaterialPropertyDerivative<Real>("QM_name", getVar("cv", 0)->name())),
    _dQp(getMaterialPropertyDerivative<Real>("Q_name", getVar("cp", 0)->name())),
    _dQMp(getMaterialPropertyDerivative<Real>("QM_name", getVar("cp", 0)->name())),
    _dQM(getMaterialPropertyDerivative<Real>("QM_name", _var.name()))
{
}

Real
Migration::computeQpResidual()
{
  return _Q[_qp] * _grad_cv[_qp] * _grad_test[_i][_qp] +
         _QM[_qp] * _grad_cp[_qp] * _grad_test[_i][_qp];
}

Real
Migration::computeQpJacobian()
{
  return _dQ[_qp] * _grad_cv[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp] +
         _dQM[_qp] * _grad_cp[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp];
}
Real
Migration::computeQpOffDiagJacobian(unsigned int jvar)
{
  if (jvar == _cp_var)
    return _QM[_qp] * _grad_phi[_j][_qp] * _grad_test[_i][_qp] +
           _dQp[_qp] * _grad_cv[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp] +
           _dQMp[_qp] * _grad_cp[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp];
  else if (jvar == _cv_var)
    return _Q[_qp] * _grad_phi[_j][_qp] * _grad_test[_i][_qp] +
           _dQv[_qp] * _grad_cv[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp] +
           _dQMv[_qp] * _grad_cp[_qp] * _grad_test[_i][_qp] * _phi[_j][_qp];
  else
    return 0;
}
