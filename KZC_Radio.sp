#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "AzaZPPL"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

#define STATIONSFILE			"cfg/sourcemod/KZC_Radio.cfg"
#define MAX_STATION_NAME_SIZE	32
#define MAX_STATION_URL_SIZE	192

EngineVersion g_Game;

enum RadioOptions
{
	Radio_Volume, 
	Radio_Off, 
	Radio_Help, 
}

Menu headmenu, volumemenu, helpmenu, stationsmenu;
Handle radioName, radioUrl, radioClientVolume, radioClientUrl;

public Plugin myinfo = 
{
	name = "radio", 
	author = PLUGIN_AUTHOR, 
	description = "radio plugin for KZ-Climb", 
	version = PLUGIN_VERSION, 
	url = "http://kz-climb.com"
};

public void OnPluginStart()
{
	g_Game = GetEngineVersion();
	if (g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");
	}
	
	RegConsoleCmd("sm_radio", Menu_Head);
	RegConsoleCmd("sm_volume", Change_Volume);
	
	radioName = CreateArray(512);
	radioUrl = CreateArray(512);
	radioClientVolume = CreateArray(64);
	radioClientUrl = CreateArray(64);
	
	LoadWebshortcuts();
	
	stationsmenu = new Menu(StationsMenuHandler);
	stationsmenu.SetTitle("KZ-Climb Radio Options");
	
	for (int i; i < 64; i++)
	{
		PushArrayString(radioClientVolume, "20");
		PushArrayString(radioClientUrl, "");
	}
	
	for (int i; i < GetArraySize(radioName); ++i)
	{
		char name[512];
		char link[512];
		
		GetArrayString(radioName, i, name, sizeof(name));
		GetArrayString(radioUrl, i, link, sizeof(link));
		
		stationsmenu.AddItem(link, name);
		stationsmenu.ExitButton = true;
	}
	
	// Head Menu
	headmenu = new Menu(HeadMenuHandler);
	headmenu.SetTitle("KZ-Climb Radio Options");
	headmenu.AddItem("radio stations", "Radio Stations");
	headmenu.AddItem("adjust volume", "Adjust Volume");
	headmenu.AddItem("radio help", "Help");
	headmenu.AddItem("stop radio", "Stop Radio");
	headmenu.ExitButton = true;
	
	// Volume Menu
	volumemenu = new Menu(VolumeMenuHandler);
	volumemenu.SetTitle("Volume Options");
	volumemenu.AddItem("1", "1%");
	volumemenu.AddItem("5", "5%");
	volumemenu.AddItem("10", "10%");
	volumemenu.AddItem("20", "20%");
	volumemenu.AddItem("30", "30%");
	volumemenu.AddItem("50", "50%");
	volumemenu.AddItem("75", "75%");
	volumemenu.AddItem("100", "100%");
	volumemenu.Pagination = 0;
	volumemenu.ExitButton = true;
	
	// Help Menu
	helpmenu = new Menu(HelpMenuHandler);
	helpmenu.SetTitle("Help");
	helpmenu.AddItem("0", "NOTE: You must have HTML MOTD enabled! (cl_disablehtmlmotd 0)", ITEMDRAW_DISABLED);
	helpmenu.AddItem("1", "NOTE: You must have flashplayer NPAPI and PPAPI! (press to get link in console)", ITEMDRAW_DISABLED);
	helpmenu.AddItem("2", "Type !radio to open up the main menu");
	helpmenu.AddItem("3", "Type !radiohelp to open up this menu");
	helpmenu.AddItem("4", "Type !volume 20 to change the volume. E.G '!volume 25'");
	helpmenu.ExitButton = true;
	
}

public Action Change_Volume(int client, int args)
{
	char arg1[512], url[512], listeningUrl[512];
	int vol;
	
	GetCmdArg(1, arg1, sizeof(arg1));
	
	vol = StringToInt(arg1);
	
	if(StrEqual(arg1, "0"))
		vol = 0;
	else if(vol > 100)
		vol = 100;
	else if(vol < 0)
		vol = 0;
	
	IntToString(vol, arg1, sizeof(arg1));
	
	SetArrayString(radioClientVolume, client, arg1);
	
	GetArrayString(radioClientUrl, client, listeningUrl, sizeof(listeningUrl));
	
	Format(url, sizeof(url), "http://radio.junkfoodmountain.com/?radiourl=%s&volume=%s", listeningUrl, arg1);
	
	StreamPanel("KZ-Climb", url, client);
}

public Action Menu_Head(int client, int args)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		headmenu.Display(client, 30);
	}
	
	return Plugin_Handled;
}

public int HeadMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		
		switch (param2)
		{
			case 0:
			{
				stationsmenu.Display(client, MENU_TIME_FOREVER);
			}
			case 1:
			{
				volumemenu.Display(client, MENU_TIME_FOREVER);
			}
			case 2:
			{
				helpmenu.Display(client, MENU_TIME_FOREVER);
			}
			case 3:
			{
				StreamPanel("KZ-Climb", "Thanks for listening", client);
			}
		}
	}
}

public int VolumeMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char vol[4], url[512], listeningUrl[512];
		volumemenu.GetItem(param2, vol, sizeof(vol));
		
		SetArrayString(radioClientVolume, client, vol);
		
		GetArrayString(radioClientUrl, client, listeningUrl, sizeof(listeningUrl));
		
		Format(url, sizeof(url), "http://radio.junkfoodmountain.com/?radiourl=%s&volume=%s", listeningUrl, vol);
		
		StreamPanel("KZ-Climb", url, client);
	}
	else if (action == MenuAction_Cancel)
	{
		headmenu.Display(client, 30);
	}
}

public int HelpMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		if(param2 == 1)
		{
			PrintToConsole(client, "https://get.adobe.com/flashplayer/otherversions/");
		}
		helpmenu.Display(client, MENU_TIME_FOREVER);
	}
	else if (action == MenuAction_Cancel)
	{
		headmenu.Display(client, 30);
	}
}

public int StationsMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char url[512], clientName[512], vol[4], listeningName[512], listeningUrl[512];
		
		stationsmenu.GetItem(param2, listeningUrl, sizeof(listeningUrl));
		
		GetArrayString(radioName, param2, listeningName, sizeof(listeningName));
		GetArrayString(radioClientVolume, client, vol, sizeof(vol));
		
		SetArrayString(radioClientUrl, client, listeningUrl);
		
		Format(url, sizeof(url), "http://radio.junkfoodmountain.com/?radiourl=%s&volume=%s", listeningUrl, vol);
		
		GetClientName(client, clientName, sizeof(clientName));
		PrintToChatAll("[KZC-Radio] %s Started listening to %s", clientName, listeningName);
		
		StreamPanel("KZ-Climb", url, client);
	}
	else if (action == MenuAction_Cancel)
	{
		headmenu.Display(client, 30);
	}
}

public void LoadWebshortcuts()
{
	char buffer[1024];
	BuildPath(Path_SM, buffer, sizeof(buffer), "configs/radio.cfg");
	
	if (!FileExists(buffer))
	{
		return;
	}
	
	Handle f = OpenFile(buffer, "r");
	if (f == INVALID_HANDLE)
	{
		LogError("[Radio] Could not open file: %s", buffer);
		return;
	}
	
	char name[32];
	char link[512];
	
	ClearArray(radioName);
	ClearArray(radioUrl);
	
	while (!IsEndOfFile(f) && ReadFileLine(f, buffer, sizeof(buffer)))
	{
		TrimString(buffer);
		if (buffer[0] == '\0' || buffer[0] == ';' || (buffer[0] == '/' && buffer[1] == '/'))
		{
			continue;
		}
		
		int pos = BreakString(buffer, name, sizeof(name));
		if (pos == -1)
		{
			continue;
		}
		
		strcopy(link, sizeof(link), buffer[pos]);
		TrimString(link);
		
		PushArrayString(radioName, name);
		PushArrayString(radioUrl, link);
	}
	
	CloseHandle(f);
}

public StreamPanel(char title[512], char url[512], client) {
	Handle Radio = CreateKeyValues("data");
	KvSetString(Radio, "title", title);
	KvSetString(Radio, "type", "2");
	KvSetString(Radio, "msg", url);
	ShowVGUIPanel(client, "info", Radio, false);
	CloseHandle(Radio);
}