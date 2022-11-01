//
//  YPPRouterConst.h
//  Lighting
//
//  Created by lujinhui on 2020/3/6.
//

#ifndef YPPRouterConst_h
#define YPPRouterConst_h

#import "YPPLog.h"

// 旧有定义，待删除
#define SCHEME_FUNC_PAGE                 @"page"
#define SCHEME_FUNC_WEBPAGE              @"webpage"
#define SCHEME_FUNC_PLUGIN               @"plugin"
#define SCHEME_FUNC_NATIVEPAGE           @"npage"
#define SCHEME_FUNC_STORE                @"appstore"
#define SCHEME_EXTRA_PAGE_PUSH           @"push"
#define SCHEME_EXTRA_PAGE_PRESENT        @"present"
#define SCHEME_PARAM_WEBPAGE_URL         @"url"
#define SCHEME_PARAM_STORE               @"appid"
#define SCHEME_PARAM_EXTENTSION_PARAMA   @"extensionParams"

#define SCHEME_PLIST_NAME                @"urlscheme_"
#define SCHEME_PAGE_NAME                 @"urlpagescheme_"

#define ROUTER_PAGENAME_KEY              @"PageName"
#define ROUTER_PAGE_BUSINESSNAME_KEY     @"BusinessName"
#define ROUTER_PLUGINNAME_KEY            @"PluginName"
#define ROUTER_CLASSNAME_KEY             @"ClassName"
#define ROUTER_ISCLASSMETHOD_KEY         @"IsClassMethod"
#define ROUTER_CALLFUNCNAME_KEY          @"CallFuncName"

#define ROUTER_QUICKPAGEFUNCNAME        quickPageFunction:
#define ROUTER_QUICKPAGEFUNCNAMESTR     @"quickPageFunction:"

#define ROUTER_QUICKADDPAGESCHEME(businessName, pageName, className)\
@{ROUTER_PAGE_BUSINESSNAME_KEY:businessName,ROUTER_PAGENAME_KEY:pageName,ROUTER_CLASSNAME_KEY:className}


#endif /* YPPRouterConst_h */
