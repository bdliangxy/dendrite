#include "DendriteApp.h"
#include "Moose.h"
#include "AppFactory.h"
#include "ModulesApp.h"
#include "MooseSyntax.h"

InputParameters
DendriteApp::validParams()
{
  InputParameters params = MooseApp::validParams();
  params.set<bool>("use_legacy_material_output") = false;
  params.set<bool>("use_legacy_initial_residual_evaluation_behavior") = false;
  return params;
}

DendriteApp::DendriteApp(const InputParameters & parameters) : MooseApp(parameters)
{
  DendriteApp::registerAll(_factory, _action_factory, _syntax);
}

DendriteApp::~DendriteApp() {}

void
DendriteApp::registerAll(Factory & f, ActionFactory & af, Syntax & syntax)
{
  ModulesApp::registerAllObjects<DendriteApp>(f, af, syntax);
  Registry::registerObjectsTo(f, {"DendriteApp"});
  Registry::registerActionsTo(af, {"DendriteApp"});

  /* register custom execute flags, action syntax, etc. here */
}

void
DendriteApp::registerApps()
{
  registerApp(DendriteApp);
}

/***************************************************************************************************
 *********************** Dynamic Library Entry Points - DO NOT MODIFY ******************************
 **************************************************************************************************/
extern "C" void
DendriteApp__registerAll(Factory & f, ActionFactory & af, Syntax & s)
{
  DendriteApp::registerAll(f, af, s);
}
extern "C" void
DendriteApp__registerApps()
{
  DendriteApp::registerApps();
}
