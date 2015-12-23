#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "AzaZPPL"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

EngineVersion g_Game;
Menu headmenu;
Menu volumemenu;
Menu helpmenu;

enum RadioOptions
{
	Radio_Volume,
	Radio_Off,
	Radio_Help,
}


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
	if(g_Game != Engine_CSGO && g_Game != Engine_CSS)
	{
		SetFailState("This plugin is for CSGO/CSS only.");	
	}
	
	RegConsoleCmd("sm_radio", Menu_Head);
	
	// Head Menu
	headmenu = new Menu(HeadMenuHandler);
	headmenu.SetTitle("KZ-Climb Radio Options");
	headmenu.AddItem("radio stations", "Radio Stations");
	headmenu.AddItem("adjust volume", "Adjust Volume");
	headmenu.AddItem("radio help", "Help");
	headmenu.ExitButton = true;
	
	// Volume Menu
	volumemenu = new Menu(VolumeMenuHandler);
	volumemenu.SetTitle("Volume Options");
	volumemenu.AddItem("1", "1");
	volumemenu.AddItem("5", "5");
	volumemenu.AddItem("10", "10");
	volumemenu.AddItem("20", "20");
	volumemenu.AddItem("30", "30");
	volumemenu.AddItem("40", "40");
	volumemenu.AddItem("50", "50");
	volumemenu.AddItem("75", "75");
	volumemenu.AddItem("100", "100");
	volumemenu.ExitButton = true;
	
	// Help Menu
	helpmenu = new Menu(HelpMenuHandler);
	helpmenu.SetTitle("Help");
	helpmenu.AddItem("0", "NOTE: You must have HTML MOTD enabled! (cl_disablehtmlmotd 0)", ITEMDRAW_DISABLED);
	helpmenu.AddItem("1", "Type !radio to open up the main menu");
	helpmenu.AddItem("2", "Type !radiohelp to open up this menu");
	helpmenu.AddItem("3", "Type !volume 20 to change the volume. E.G '!volume 25'");
	helpmenu.ExitButton = true;
}

public Action Menu_Head(int client, int args)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		headmenu.Display(client, 30);
	}
	
	return Plugin_Handled;
}

public int HeadMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				
			}
			case 1:
			{
				volumemenu.Display(client, MENU_TIME_FOREVER);
			}
			case 2:
			{
				helpmenu.Display(client, MENU_TIME_FOREVER);
			}
		}
	}
}

public int VolumeMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				
			}
			case 1:
			{
				
			}
			case 2:
			{
				
			}
		}
	}
}

public int HelpMenuHandler(Menu menu, MenuAction action, int client, int param2)
{
	if(action == MenuAction_Select)
	{
		switch (param2)
		{
			case 0:
			{
				
			}
			case 1:
			{
				
			}
			case 2:
			{
				
			}
		}
	}
}