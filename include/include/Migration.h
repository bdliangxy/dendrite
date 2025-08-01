/****************************************************************/
/* MOOSE - Multiphysics Object Oriented Simulation Environment  */
/*                                                              */
/*          All contents are licensed under LGPL V2.1           */
/*             See LICENSE for full restrictions                */
/****************************************************************/
#ifndef Migration_H
#define Migration_H

#include "Kernel.h"
#include "DerivativeMaterialInterface.h"

/*class Migration;

template <>
InputParameters validParams<Migration>();*/

class Migration : public DerivativeMaterialInterface<Kernel>
{
public:
  Migration(const InputParameters &parameters);

  static InputParameters validParams();

protected:
  virtual Real computeQpResidual();
  virtual Real computeQpJacobian();
  virtual Real computeQpOffDiagJacobian(unsigned int jvar);
  unsigned int _cp_var;
  const VariableValue &_cp;
  unsigned int _cv_var;
  const VariableValue &_cv;
  const VariableGradient &_grad_cp;
  const VariableGradient &_grad_cv;
  /// Mobility
  const MaterialProperty<Real> &_Q;
  const MaterialProperty<Real> &_QM;
  const MaterialProperty<Real> &_dQ;
  const MaterialProperty<Real> &_dQv;
  const MaterialProperty<Real> &_dQMv;
  const MaterialProperty<Real> &_dQp;
  const MaterialProperty<Real> &_dQMp;
  const MaterialProperty<Real> &_dQM;
  /// Interfacial parameter
};

#endif // Migration_H
