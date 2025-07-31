//* This file is part of the MOOSE framework
//* https://mooseframework.inl.gov
//*
//* All rights reserved, see COPYRIGHT for full restrictions
//* https://github.com/idaholab/moose/blob/master/COPYRIGHT
//*
//* Licensed under LGPL 2.1, please see LICENSE for details
//* https://www.gnu.org/licenses/lgpl-2.1.html
#include "DendriteTestApp.h"
#include "DendriteApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "MooseSyntax.h"

InputParameters
DendriteTestApp::validParams()
{
  InputParameters params = DendriteApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

DendriteTestApp::DendriteTestApp(const InputParameters & parameters) : MooseApp(parameters)
{
  DendriteTestApp::registerAll(
      _factory, _action_factory, _syntax, getParam<bool>("allow_test_objects"));
}

DendriteTestApp::~DendriteTestApp() {}

void
DendriteTestApp::registerAll(Factory & f, ActionFactory & af, Syntax & s, bool use_test_objs)
{
  DendriteApp::registerAll(f, af, s);
  if (use_test_objs)
  {
    Registry::registerObjectsTo(f, {"DendriteTestApp"});
    Registry::registerActionsTo(af, {"DendriteTestApp"});
  }
}

void
DendriteTestApp::registerApps()
{
  registerApp(DendriteApp);
  registerApp(DendriteTestApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
// External entry point for dynamic application loading
extern "C" void
DendriteTestApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  DendriteTestApp::registerAll(f, af, s);
}
extern "C" void
DendriteTestApp__registerApps()
{
  DendriteTestApp::registerApps();
}
