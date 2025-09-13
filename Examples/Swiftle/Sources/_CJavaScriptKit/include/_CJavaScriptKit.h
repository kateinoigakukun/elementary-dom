#ifndef _CJavaScriptKit_h
#define _CJavaScriptKit_h

#if __has_include("stdlib.h")
#include <stdlib.h>
#else
#include <stddef.h>
#endif
#include <stdbool.h>
#include <stdint.h>

/// `JavaScriptObjectRef` represents JavaScript object reference that is referenced by Swift side.
/// This value is an address of `SwiftRuntimeHeap`.
typedef unsigned int JavaScriptObjectRef;
/// `JavaScriptHostFuncRef` represents Swift closure that is referenced by JavaScript side.
/// This value is produced by `JSClosure`.
typedef uintptr_t JavaScriptHostFuncRef;

/// `JavaScriptValueKind` represents the kind of JavaScript primitive value.
typedef enum __attribute__((enum_extensibility(closed))) {
  JavaScriptValueKindBoolean = 0,
  JavaScriptValueKindString = 1,
  JavaScriptValueKindNumber = 2,
  JavaScriptValueKindObject = 3,
  JavaScriptValueKindNull = 4,
  JavaScriptValueKindUndefined = 5,
  JavaScriptValueKindFunction = 6,
} JavaScriptValueKind;

typedef uint32_t JavaScriptRawValueKindAndFlags;

typedef unsigned JavaScriptPayload1;
typedef double JavaScriptPayload2;

/// `RawJSValue` is abstract representation of JavaScript primitive value.
///
/// For boolean value:
///    payload1: 1 or 0
///    payload2: 0
///
/// For string value:
///    payload1: `JavaScriptObjectRef` of string
///    payload2: 0
///
/// For number value:
///    payload1: 0
///    payload2: double number
///
/// For object value:
///    payload1: `JavaScriptObjectRef`
///    payload2: 0
/// For null value:
///    payload1: 0
///    payload2: 0
///
/// For undefined value:
///    payload1: 0
///    payload2: 0
///
/// For function value:
///    payload1: the target `JavaScriptHostFuncRef`
///    payload2: 0
///
/// For symbol and bigint values:
///    payload1: `JavaScriptObjectRef`
///    payload2: 0
///
typedef struct {
  JavaScriptValueKind kind;
  JavaScriptPayload1 payload1;
  JavaScriptPayload2 payload2;
} RawJSValue;

#if __wasm32__
# define IMPORT_JS_FUNCTION(name, returns, args) \
__attribute__((__import_module__("javascript_kit"), __import_name__(#name))) extern returns name args;
#else
# define IMPORT_JS_FUNCTION(name, returns, args) \
  static inline returns name args { \
    abort(); \
  }
#endif

/// Sets a value of `_this` JavaScript object.
///
/// @param _this The target JavaScript object to set the given value.
/// @param prop A JavaScript string object to reference a member of `_this` object.
/// @param kind A kind of JavaScript value to set the target object.
/// @param payload1 The first payload of JavaScript value to set the target object.
/// @param payload2 The second payload of JavaScript value to set the target object.
IMPORT_JS_FUNCTION(swjs_set_prop, void, (const JavaScriptObjectRef _this,
                                         const JavaScriptObjectRef prop,
                                         const JavaScriptValueKind kind,
                                         const JavaScriptPayload1 payload1,
                                         const JavaScriptPayload2 payload2))

/// Gets a value of `_this` JavaScript object.
///
/// @param _this The target JavaScript object to get its member value.
/// @param prop A JavaScript string object to reference a member of `_this` object.
/// @param payload1 A result pointer of first payload of JavaScript value to set the target object.
/// @param payload2 A result pointer of second payload of JavaScript value to set the target object.
/// @return A `JavaScriptValueKind` bits represented as 32bit integer for the returned value.
IMPORT_JS_FUNCTION(swjs_get_prop, uint32_t, (const JavaScriptObjectRef _this,
                                             const JavaScriptObjectRef prop,
                                             JavaScriptPayload1 * _Nonnull payload1,
                                             JavaScriptPayload2 * _Nonnull payload2))

/// Sets a value of `_this` JavaScript object.
///
/// @param _this The target JavaScript object to set its member value.
/// @param index A subscript index to set value.
/// @param kind A kind of JavaScript value to set the target object.
/// @param payload1 The first payload of JavaScript value to set the target object.
/// @param payload2 The second payload of JavaScript value to set the target object.
IMPORT_JS_FUNCTION(swjs_set_subscript, void, (const JavaScriptObjectRef _this,
                                              const int index,
                                              const JavaScriptValueKind kind,
                                              const JavaScriptPayload1 payload1,
                                              const JavaScriptPayload2 payload2))

/// Gets a value of `_this` JavaScript object.
///
/// @param _this The target JavaScript object to get its member value.
/// @param index A subscript index to get value.
/// @param payload1 A result pointer of first payload of JavaScript value to get the target object.
/// @param payload2 A result pointer of second payload of JavaScript value to get the target object.
/// @return A `JavaScriptValueKind` bits represented as 32bit integer for the returned value.
/// get a value of `_this` JavaScript object.
IMPORT_JS_FUNCTION(swjs_get_subscript, uint32_t, (const JavaScriptObjectRef _this,
                                                  const int index,
                                                  JavaScriptPayload1 * _Nonnull payload1,
                                                  JavaScriptPayload2 * _Nonnull payload2))

/// Encodes the `str_obj` to bytes sequence and returns the length of bytes.
///
/// @param str_obj A JavaScript string object ref to encode.
/// @param bytes_result A result pointer of bytes sequence representation in JavaScript.
///                    This value will be used to load the actual bytes using `_load_string`.
/// @result The length of bytes sequence. This value will be used to allocate Swift side string buffer to load the actual bytes.
IMPORT_JS_FUNCTION(swjs_encode_string, int, (const JavaScriptObjectRef str_obj, JavaScriptObjectRef * _Nonnull bytes_result))

/// Decodes the given bytes sequence into JavaScript string object.
///
/// @param bytes_ptr A `uint8_t` byte sequence to decode.
/// @param length The length of `bytes_ptr`.
/// @result The decoded JavaScript string object.
IMPORT_JS_FUNCTION(swjs_decode_string, JavaScriptObjectRef, (const unsigned char * _Nonnull bytes_ptr, const int length))

/// Loads the actual bytes sequence of `bytes` into `buffer` which is a Swift side memory address.
///
/// @param bytes A bytes sequence representation in JavaScript to load. This value should be derived from `_encode_string`.
/// @param buffer A Swift side string buffer to load the bytes.
IMPORT_JS_FUNCTION(swjs_load_string, void, (const JavaScriptObjectRef bytes, unsigned char * _Nonnull buffer))

/// Converts the provided Int64 or UInt64 to a BigInt in slow path by splitting 64bit integer to two 32bit integers
/// to avoid depending on [JS-BigInt-integration](https://github.com/WebAssembly/JS-BigInt-integration) feature
///
/// @param lower The lower 32bit of the value to convert.
/// @param upper The upper 32bit of the value to convert.
/// @param is_signed Whether to treat the value as a signed integer or not.
IMPORT_JS_FUNCTION(swjs_i64_to_bigint_slow, JavaScriptObjectRef, (unsigned int lower, unsigned int upper, bool is_signed))

/// Calls JavaScript function with given arguments list.
///
/// @param ref The target JavaScript function to call.
/// @param argv A list of `RawJSValue` arguments to apply.
/// @param argc The length of `argv``.
/// @param result_payload1 A result pointer of first payload of JavaScript value of returned result or thrown exception.
/// @param result_payload2 A result pointer of second payload of JavaScript value of returned result or thrown exception.
/// @return A `JavaScriptValueKindAndFlags` bits represented as 32bit integer for the returned value.
IMPORT_JS_FUNCTION(swjs_call_function, uint32_t, (const JavaScriptObjectRef ref,
                                                  const RawJSValue * _Nullable argv,
                                                  const int argc,
                                                  JavaScriptPayload1 * _Nonnull result_payload1,
                                                  JavaScriptPayload2 * _Nonnull result_payload2))

/// Calls JavaScript function with given arguments list without capturing any exception
///
/// @param ref The target JavaScript function to call.
/// @param argv A list of `RawJSValue` arguments to apply.
/// @param argc The length of `argv``.
/// @param result_payload1 A result pointer of first payload of JavaScript value of returned result or thrown exception.
/// @param result_payload2 A result pointer of second payload of JavaScript value of returned result or thrown exception.
/// @return A `JavaScriptValueKindAndFlags` bits represented as 32bit integer for the returned value.
IMPORT_JS_FUNCTION(swjs_call_function_no_catch, uint32_t, (const JavaScriptObjectRef ref,
                                                           const RawJSValue * _Nullable argv,
                                                           const int argc,
                                                           JavaScriptPayload1 * _Nonnull result_payload1,
                                                           JavaScriptPayload2 * _Nonnull result_payload2))

/// Calls JavaScript function with given arguments list and given `_this`.
///
/// @param _this The value of `this` provided for the call to `func_ref`.
/// @param func_ref The target JavaScript function to call.
/// @param argv A list of `RawJSValue` arguments to apply.
/// @param argc The length of `argv``.
/// @param result_payload1 A result pointer of first payload of JavaScript value of returned result or thrown exception.
/// @param result_payload2 A result pointer of second payload of JavaScript value of returned result or thrown exception.
/// @return A `JavaScriptValueKindAndFlags` bits represented as 32bit integer for the returned value.
IMPORT_JS_FUNCTION(swjs_call_function_with_this, uint32_t, (const JavaScriptObjectRef _this,
                                                            const JavaScriptObjectRef func_ref,
                                                            const RawJSValue * _Nullable argv,
                                                            const int argc,
                                                            JavaScriptPayload1 * _Nonnull result_payload1,
                                                            JavaScriptPayload2 * _Nonnull result_payload2))

/// Calls JavaScript function with given arguments list and given `_this` without capturing any exception.
///
/// @param _this The value of `this` provided for the call to `func_ref`.
/// @param func_ref The target JavaScript function to call.
/// @param argv A list of `RawJSValue` arguments to apply.
/// @param argc The length of `argv``.
/// @param result_payload1 A result pointer of first payload of JavaScript value of returned result or thrown exception.
/// @param result_payload2 A result pointer of second payload of JavaScript value of returned result or thrown exception.
/// @return A `JavaScriptValueKindAndFlags` bits represented as 32bit integer for the returned value.
IMPORT_JS_FUNCTION(swjs_call_function_with_this_no_catch, uint32_t, (const JavaScriptObjectRef _this,
                                                                     const JavaScriptObjectRef func_ref,
                                                                     const RawJSValue * _Nullable argv,
                                                                     const int argc,
                                                                     JavaScriptPayload1 * _Nonnull result_payload1,
                                                                     JavaScriptPayload2 * _Nonnull result_payload2))

/// Calls JavaScript object constructor with given arguments list.
///
/// @param ref The target JavaScript constructor to call.
/// @param argv A list of `RawJSValue` arguments to apply.
/// @param argc The length of `argv``.
/// @returns A reference to the constructed object.
IMPORT_JS_FUNCTION(swjs_call_new, JavaScriptObjectRef, (const JavaScriptObjectRef ref,
                                                        const RawJSValue * _Nullable argv,
                                                        const int argc))

/// Calls JavaScript object constructor with given arguments list.
///
/// @param ref The target JavaScript constructor to call.
/// @param argv A list of `RawJSValue` arguments to apply.
/// @param argc The length of `argv``.
/// @param exception_kind A result pointer of JavaScript value kind of thrown exception.
/// @param exception_payload1 A result pointer of first payload of JavaScript value of thrown exception.
/// @param exception_payload2 A result pointer of second payload of JavaScript value of thrown exception.
/// @returns A reference to the constructed object.
IMPORT_JS_FUNCTION(swjs_call_throwing_new, JavaScriptObjectRef, (const JavaScriptObjectRef ref,
                                                                 const RawJSValue * _Nullable argv,
                                                                 const int argc,
                                                                 JavaScriptRawValueKindAndFlags * _Nonnull exception_kind,
                                                                 JavaScriptPayload1 * _Nonnull exception_payload1,
                                                                 JavaScriptPayload2 * _Nonnull exception_payload2))

/// Acts like JavaScript `instanceof` operator.
///
/// @param obj The target object to check its prototype chain.
/// @param constructor The `constructor` object to check against.
/// @result Return `true` if `constructor` appears anywhere in the prototype chain of `obj`. Return `false` if not.
IMPORT_JS_FUNCTION(swjs_instanceof, bool, (const JavaScriptObjectRef obj,
                                           const JavaScriptObjectRef constructor))

/// Acts like JavaScript `==` operator.
/// Performs "==" comparison, a.k.a the "Abstract Equality Comparison"
/// algorithm defined in the ECMAScript.
/// https://262.ecma-international.org/11.0/#sec-abstract-equality-comparison
///
/// @param lhs The left-hand side value to compare.
/// @param rhs The right-hand side value to compare.
/// @result Return `true` if `lhs` is `==` to `rhs`. Return `false` if not.
IMPORT_JS_FUNCTION(swjs_value_equals, bool, (const JavaScriptObjectRef lhs, const JavaScriptObjectRef rhs))
/// Decrements reference count of `ref` retained by `SwiftRuntimeHeap` in JavaScript side.
///
/// @param ref The target JavaScript object.
IMPORT_JS_FUNCTION(swjs_release, void, (const JavaScriptObjectRef ref))

IMPORT_JS_FUNCTION(swjs_create_object, JavaScriptObjectRef, (void))

#endif /* _CJavaScriptKit_h */
