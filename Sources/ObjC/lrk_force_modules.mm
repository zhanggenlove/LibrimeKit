// lrk_force_modules.mm
//
// Force-links librime plugin modules that are NOT part of librime's
// default module set (core / dict / gears / levers). The lua plugin
// is one such module: nothing in librime's static build references
// it, so the linker would dead-strip its object files — dropping the
// `RIME_REGISTER_MODULE(lua)` static initializer and leaving the
// module unregistered. The symptom is that every `lua_translator@…`
// / `lua_filter@…` silently fails to instantiate (date/time, 农历,
// 计算器, 错音错字, 置顶候选 … all missing) while pinyin still works.
//
// `rime_require_module_lua` has C++ linkage in librime, so it must be
// referenced from a C++ (ObjC++) translation unit. We expose a
// C-linkage wrapper that the ObjC bridge (`lrk_api.m`) calls from a
// load-time constructor, anchoring the whole chain into the binary.
//
// Loading still requires "lua" in `RimeTraits.modules`; this only
// guarantees the module is *registered* and available to load.

extern void rime_require_module_lua();

extern "C" void lrk_force_link_plugin_modules(void) {
    rime_require_module_lua();
}
