
/* Extension Helper - SteamTools */

void Download_SteamTools(const char[] url, const char[] dest)
{
	char sURL[MAX_URL_LENGTH];
	PrefixURL(sURL, sizeof(sURL), url);
	
	DataPack hDLPack = new DataPack();
	hDLPack.WriteString(dest);

	HTTPRequestHandle hRequest = Steam_CreateHTTPRequest(HTTPMethod_GET, sURL);
	Steam_SetHTTPRequestHeaderValue(hRequest, "Pragma", "no-cache");
	Steam_SetHTTPRequestHeaderValue(hRequest, "Cache-Control", "no-cache");
	Steam_SendHTTPRequest(hRequest, OnSteamHTTPComplete, hDLPack);
}

public void OnSteamHTTPComplete(HTTPRequestHandle HTTPRequest, bool requestSuccessful, HTTPStatusCode statusCode, DataPack hDLPack)
{
	char sDest[PLATFORM_MAX_PATH];
	hDLPack.Reset();
	hDLPack.ReadString(sDest, sizeof(sDest));
	delete hDLPack;
	
	if (requestSuccessful && statusCode == HTTPStatusCode_OK)
	{
		Steam_WriteHTTPResponseBody(HTTPRequest, sDest);
		DownloadEnded(true);
	}
	else
	{
		char sError[256];
		FormatEx(sError, sizeof(sError), "SteamTools error (status code %i). Request successful: %s", _:statusCode, requestSuccessful ? "True" : "False");
		DownloadEnded(false, sError);
	}
	
	Steam_ReleaseHTTPRequest(HTTPRequest);
}

/* Keep track of SteamTools load state. */
bool g_bSteamLoaded;

public void Steam_FullyLoaded()
{
	g_bSteamLoaded = true;
}

public void Steam_Shutdown()
{
	g_bSteamLoaded = false;
}
