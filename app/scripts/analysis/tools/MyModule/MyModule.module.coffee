'use strict'

Module = require 'scripts/BaseClasses/BaseModule.coffee'
module.exports = myModule = new Module

  id: 'socrat_analysis_mymodule'

  components:
    services:
      'socrat_analysis_mymodule_initService': require 'scripts/analysis/tools/MyModule/MyModuleInit.service.coffee'
      'socrat_analysis_mymodule_msgService': require 'scripts/analysis/tools/MyModule/MyModuleMsgService.service.coffee'
      'socrat_analysis_mymodule_dataService': require 'scripts/analysis/tools/MyModule/MyModuleDataService.service.coffee'
      'socrat_analysis_mymodule_myService': require 'scripts/analysis/tools/MyModule/MyModuleMyService.service.coffee'
      # 'socrat_analysis_mymodule_standardization' : require 'scripts/analysis/tools/MyModule/MyModuleStandardization.service.coffee'
    controllers:
      'mymoduleMainCtrl': require 'scripts/analysis/tools/MyModule/MyModuleMainCtrl.ctrl.coffee'
      'mymoduleSidebarCtrl': require 'scripts/analysis/tools/MyModule/MyModuleSidebarCtrl.ctrl.coffee'
    directives:
      'socratMyModuleDir': require 'scripts/analysis/tools/MyModule/MyModuleDir.directive.coffee'

# module state config
  state:
# module name to show in UI
    name: 'My Awesome Module'
    url: '/tools/mymodule'
    mainTemplate: require 'partials/analysis/tools/MyModule/main.jade'
    sidebarTemplate: require 'partials/analysis/tools/MyModule/sidebar.jade'
