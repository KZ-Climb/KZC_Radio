#pragma semicolon 1

#include <sourcemod>

public Plugin myinfo = 
{
	name = "KZC_Radio", 
	author = "AzaZPPL", 
	description = "Radio plugin for KZ-Climb",
	version = "1.3", 
	url = "http://kz-climb.com"
};

#define MAX_USERNAME_SIZE	32
#define MAX_NAME_SIZE	32
#define MAX_URL_SIZE	512

enum ClientOptions
{
	String:Name[MAX_USERNAME_SIZE],
	String:Radio_Name[MAX_NAME_SIZE],
	String:Radio_Url[MAX_URL_SIZE],
	bool:Radio_On,
	Radio_Vol,
}

Menu headmenu, volumemenu, helpmenu, stationsmenu;
Handle radioName, radioUrl, radioClientWelcomeMessage[MAXPLAYERS+1];

h_client[MAXPLAYERS + 1][ClientOptions];

public void OnPluginStart()
{
	RegConsoleCmd("sm_radio", Menu_Head);
	RegConsoleCmd("sm_volume", Change_Volume);
	RegConsoleCmd("sm_stopradio", StopRadio);
	
	radioName = CreateArray(MAX_NAME_SIZE);
	radioUrl = CreateArray(MAX_URL_SIZE);
	
	LoadWebshortcuts();
	SetupMenu();
	
}

public void OnClientPutInServer(int client)
{
	radioClientWelcomeMessage[client] = CreateTimer(20.00, Welcome_Message, client);
	
	// Set default values for connected client
	FormatEx(h_client[client][Radio_Name], MAX_NAME_SIZE, "");
	FormatEx(h_client[client][Radio_Url], MAX_URL_SIZE, "");
	h_client[client][Radio_On] = false;
	h_client[client][Radio_Vol] = 20;
}

public void OnClientDisconnect(int client)
{
	if (radioClientWelcomeMessage[client] != null)
	{
		KillTimer(radioClientWelcomeMessage[client]);
		radioClientWelcomeMessage[client] = null;
	}
}

public Action Welcome_Message(Handle h_timer, int client)
{
	PrintToChat(client, "%s", " \x03[\x02KZC-Radio\x03]\x01 Welcome! This server is using KZC-Radio!");
	PrintToChat(client, "%s", " \x03[\x02KZC-Radio\x03]\x01 Type in !radio for the radio menu!");
	
	radioClientWelcomeMessage[client] = null;
}

public void SetupMenu()
{
	stationsmenu = new Menu(StationsMenuHandler);
	stationsmenu.SetTitle("KZ-Climb Radio Options");
	
	for (int i; i < GetArraySize(radioName); ++i)
	{
		char name[MAX_NAME_SIZE], link[MAX_URL_SIZE];
		
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
	helpmenu.AddItem("0", "NOTE: You must have HTML MOTD enabled! (cl_disablehtmlmotd 0)");
	helpmenu.AddItem("1", "NOTE: You must have flashplayer NPAPI and PPAPI! (press to get link in console)");
	helpmenu.AddItem("2", "Type !radio to open up the main menu");
	helpmenu.AddItem("3", "Type !radiohelp to open up this menu");
	helpmenu.AddItem("4", "Type !volume 20 to change the volume. E.G '!volume 25'");
	helpmenu.AddItem("5", "Type !stopradio to stop the radio");
	helpmenu.ExitButton = true;
}

public Action Change_Volume(int client, int args)
{
	char userInput[MAX_URL_SIZE], url[MAX_URL_SIZE];
	int vol;
	
	GetCmdArg(1, userInput, sizeof(userInput));
	
	vol = StringToInt(userInput);
	
	if(vol > 100)
		vol = 100;
	else if(vol < 0)
		vol = 0;
	
	h_client[client][Radio_On] = true;
	h_client[client][Radio_Vol] = vol;
	
	FormatEx(url, sizeof(url), "http://radio.junkfoodmountain.com/?radiourl=%s&volume=%i", h_client[client][Radio_Url], vol);
	
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
				StopRadio(client, 0);
			}
		}
	}
}

public int VolumeMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if (action == MenuAction_Select)
	{
		char userInput[4], url[MAX_URL_SIZE];
		volumemenu.GetItem(param2, userInput, sizeof(userInput));
		
		h_client[client][Radio_On] = true;
		h_client[client][Radio_Vol] = StringToInt(userInput);
		
		FormatEx(url, sizeof(url), "http://radio.junkfoodmountain.com/?radiourl=%s&volume=%i", h_client[client][Radio_Url], h_client[client][Radio_Vol]);
		
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
		char url[MAX_URL_SIZE];
		
		stationsmenu.GetItem(param2, h_client[client][Radio_Url], MAX_URL_SIZE);
		stationsmenu.GetItem(param2, "", 0, _, h_client[client][Radio_Name], MAX_NAME_SIZE);
		
		h_client[client][Radio_On] = true;
		
		FormatEx(url, sizeof(url), "http://radio.junkfoodmountain.com/?radiourl=%s&volume=%i", h_client[client][Radio_Url], h_client[client][Radio_Vol]);
		
		GetClientName(client, h_client[client][Name], MAX_USERNAME_SIZE);
		PrintToChatAll(" \x03[\x02KZC-Radio\x03]\x01 %s Started listening to %s", h_client[client][Name], h_client[client][Radio_Name]);
		
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
		LogError("[KZC-Radio] Could not open file: %s", buffer);
		return;
	}
	
	char name[MAX_NAME_SIZE], link[MAX_URL_SIZE];
	
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

public void StreamPanel(char title[128], char url[MAX_URL_SIZE], int client) 
{
	Handle Radio = CreateKeyValues("data");
	KvSetString(Radio, "title", title);
	KvSetString(Radio, "type", "2");
	KvSetString(Radio, "msg", url);
	ShowVGUIPanel(client, "info", Radio, false);
	CloseHandle(Radio);
}

public Action StopRadio(int client, int args)
{
	if (client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		StreamPanel("KZ-Climb", "Thanks for listening", client);
	}
}