package vermaindustries.keep_chatting

import io.flutter.plugin.common.PluginRegistry

class FirebaseCloudMessagingPlugin {
    fun registerWith(pluginRegistry: PluginRegistry){
        if(alreadyRegisterWith(pluginRegistry)) return
        registerWith(pluginRegistry)
    }
    private  fun alreadyRegisterWith(pluginRegistry:PluginRegistry):Boolean{
        val key = FirebaseCloudMessagingPlugin::class.java.canonicalName
        if(pluginRegistry.hasPlugin(key)) return true
        pluginRegistry.registrarFor(key)
        return false
    }
}