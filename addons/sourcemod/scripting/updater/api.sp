
/* API - Natives & Forwards */

static PrivateForward fwd_OnPluginChecking = null;
static PrivateForward fwd_OnPluginDownloading = null;
static PrivateForward fwd_OnPluginUpdating = null;
static PrivateForward fwd_OnPluginUpdated = null;
static PrivateForward fwd_CanPluginReload = null;

void API_Init()
{
	CreateNative("Updater_AddPlugin", Native_AddPlugin);
	CreateNative("Updater_RemovePlugin", Native_RemovePlugin);
	CreateNative("Updater_ForceUpdate", Native_ForceUpdate);
	
	fwd_OnPluginChecking = new PrivateForward(ET_Event);
	fwd_OnPluginDownloading = new PrivateForward(ET_Event);
	fwd_OnPluginUpdating = new PrivateForward(ET_Ignore);
	fwd_OnPluginUpdated = new PrivateForward(ET_Ignore);
	fwd_CanPluginReload = new PrivateForward(ET_Event);
}

// native Updater_AddPlugin(const String:url[]);
public int Native_AddPlugin(Handle plugin, int numParams)
{
	char url[MAX_URL_LENGTH];
	GetNativeString(1, url, sizeof(url));
	
	Updater_AddPlugin(plugin, url);
}

// native Updater_RemovePlugin();
public int Native_RemovePlugin(Handle plugin, int numParams)
{
	int index = PluginToIndex(plugin);
	
	if (index != -1)
	{
		Updater_QueueRemovePlugin(plugin);
	}
	
	return 0;
}

// native bool:Updater_ForceUpdate();
public int Native_ForceUpdate(Handle plugin, int numParams)
{
	int index = PluginToIndex(plugin);
	
	if (index == -1)
	{
		ThrowNativeError(SP_ERROR_NOT_FOUND, "Plugin not found in updater.");
	}
	else if (Updater_GetStatus(index) == Status_Idle)
	{
		Updater_Check(index);
		return 1;
	}
	
	return 0;
}

// forward Action:Updater_OnPluginChecking();
Action Fwd_OnPluginChecking(Handle plugin)
{
	Action result = Plugin_Continue;
	Function func = GetFunctionByName(plugin, "Updater_OnPluginChecking");
	
	if (func != INVALID_FUNCTION && fwd_OnPluginChecking.AddFunction(plugin, func))
	{
		Call_StartForward(fwd_OnPluginChecking);
		Call_Finish(result);
		fwd_OnPluginChecking.RemoveAllFunctions(plugin);
	}
	
	return result;
}

// forward Action:Updater_OnPluginDownloading();
Action Fwd_OnPluginDownloading(Handle plugin)
{
	Action result = Plugin_Continue;
	Function func = GetFunctionByName(plugin, "Updater_OnPluginDownloading");
	
	if (func != INVALID_FUNCTION && fwd_OnPluginDownloading.AddFunction(plugin, func))
	{
		Call_StartForward(fwd_OnPluginDownloading);
		Call_Finish(result);
		fwd_OnPluginDownloading.RemoveAllFunctions(plugin);
	}
	
	return result;
}

// forward Updater_OnPluginUpdating();
void Fwd_OnPluginUpdating(Handle plugin)
{
	Function func = GetFunctionByName(plugin, "Updater_OnPluginUpdating");
	
	if (func != INVALID_FUNCTION && fwd_OnPluginUpdating.AddFunction(plugin, func))
	{
		Call_StartForward(fwd_OnPluginUpdating);
		Call_Finish();
		fwd_OnPluginUpdating.RemoveAllFunctions(plugin);
	}
}

// forward Updater_OnPluginUpdated();
void Fwd_OnPluginUpdated(Handle plugin)
{
	Function func = GetFunctionByName(plugin, "Updater_OnPluginUpdated");
	
	if (func != INVALID_FUNCTION && fwd_OnPluginUpdating.AddFunction(plugin, func))
	{
		Call_StartForward(fwd_OnPluginUpdated);
		Call_Finish();
		fwd_OnPluginUpdated.RemoveAllFunctions(plugin);
	}
}

Action Fwd_CanPluginReload(Handle plugin)
{
	Action result = Plugin_Continue;
	Function func = GetFunctionByName(plugin, "Updater_CanPluginReload");
	
	if (func != INVALID_FUNCTION && fwd_CanPluginReload.AddFunction(plugin, func))
	{
		Call_StartForward(fwd_CanPluginReload);
		Call_Finish(result);
		fwd_CanPluginReload.RemoveAllFunctions(plugin);
	}
	
	return result;
}
