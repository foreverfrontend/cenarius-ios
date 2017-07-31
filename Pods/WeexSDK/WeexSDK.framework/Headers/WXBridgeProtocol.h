/*
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 * 
 *   http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */

#import <JavaScriptCore/JavaScriptCore.h>

typedef NSInteger(^WXJSCallNative)(NSString *instance, NSArray *tasks, NSString *callback);
typedef NSInteger(^WXJSCallAddElement)(NSString *instanceId,  NSString *parentRef, NSDictionary *elementData, NSInteger index);
typedef NSInteger(^WXJSCallCreateBody)(NSString *instanceId, NSDictionary *bodyData);
typedef NSInteger(^WXJSCallRemoveElement)(NSString *instanceId,NSString *ref);
typedef NSInteger(^WXJSCallMoveElement)(NSString *instanceId,NSString *ref,NSString *parentRef,NSInteger index);
typedef NSInteger(^WXJSCallUpdateAttrs)(NSString *instanceId,NSString *ref,NSDictionary *attrsData);
typedef NSInteger(^WXJSCallUpdateStyle)(NSString *instanceId,NSString *ref,NSDictionary *stylesData);
typedef NSInteger(^WXJSCallAddEvent)(NSString *instanceId,NSString *ref,NSString *event);
typedef NSInteger(^WXJSCallRemoveEvent)(NSString *instanceId,NSString *ref,NSString *event);
typedef NSInvocation *(^WXJSCallNativeModule)(NSString *instanceId, NSString *moduleName, NSString *methodName, NSArray *args, NSDictionary *options);
typedef void (^WXJSCallNativeComponent)(NSString *instanceId, NSString *componentRef, NSString *methodName, NSArray *args, NSDictionary *options);

@protocol WXBridgeProtocol <NSObject>

@property (nonatomic, readonly) JSValue* exception;

/**
 * Executes the js framework code in javascript engine
 * You can do some setup in this method
 */
- (void)executeJSFramework:(NSString *)frameworkScript;

/**
 * Executes the js code in javascript engine
 * You can do some setup in this method
 */
- (void)executeJavascript:(NSString *)script;

/**
 * Executes global js method with specific arguments
 */
- (JSValue *)callJSMethod:(NSString *)method args:(NSArray*)args;

/**
 * Register callback when call native tasks occur
 */
- (void)registerCallNative:(WXJSCallNative)callNative;

/**
 * Reset js engine environment, called when any environment variable is changed.
 */
- (void)resetEnvironment;

@optional
/**
 * Remove instance's timer.
 */
-(void)removeTimers:(NSString *)instance;

/**
 * Called when garbage collection is wanted by sdk.
 */
- (void)garbageCollect;

/**
 * Register callback when addElement tasks occur
 */
- (void)registerCallAddElement:(WXJSCallAddElement)callAddElement;

/**
 * Register callback when createBody tasks occur
 */
- (void)registerCallCreateBody:(WXJSCallCreateBody)callCreateBody;

/**
 * Register callback when removeElement tasks occur
 */
- (void)registerCallRemoveElement:(WXJSCallRemoveElement)callRemoveElement;

/**
 * Register callback when removeElement tasks occur
 */
- (void)registerCallMoveElement:(WXJSCallMoveElement)callMoveElement;

/**
 * Register callback when updateAttrs tasks occur
 */
- (void)registerCallUpdateAttrs:(WXJSCallUpdateAttrs)callUpdateAttrs;
/**
 * Register callback when updateStyle tasks occur
 */
- (void)registerCallUpdateStyle:(WXJSCallUpdateStyle)callUpdateStyle;
/**
 * Register callback when addEvent tasks occur
 */
- (void)registerCallAddEvent:(WXJSCallAddEvent)callAddEvent;
/**
 * Register callback when removeEvent tasks occur
 */
- (void)registerCallRemoveEvent:(WXJSCallRemoveEvent)callRemoveEvent;
/**
 * Register callback for global js function `callNativeModule`
 */
- (void)registerCallNativeModule:(WXJSCallNativeModule)callNativeModuleBlock;

/**
 * Register callback for global js function `callNativeComponent`
 */
- (void)registerCallNativeComponent:(WXJSCallNativeComponent)callNativeComponentBlock;


@end