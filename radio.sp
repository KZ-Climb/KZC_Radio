#pragma semicolon 1

#define DEBUG

#define PLUGIN_AUTHOR "AzaZPPL"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>
#include <cstrike>
//#include <sdkhooks>

EngineVersion g_Game;

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
	RegConsoleCmd("sm_radiohelp", Menu_RadioHelp);
	RegConsoleCmd("sm_volume", Menu_Volume);
}

public Action Menu_Head(int client, int args)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		Menu menu = new Menu(HeadMenuHandler);
		menu.SetTitle("KZ-Climb Radio Options");
		menu.AddItem("radio stations", "Radio Stations");
		menu.AddItem("adjust volume", "Adjust Volume");
		menu.AddItem("radio help", "Help");
		menu.ExitButton = true;
		menu.Display(client, 30);
	}
	
	return Plugin_Handled;
}

public Action Menu_Volume(client, args)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		Menu menu = new Menu(VolumeMenuHandler);
		menu.SetTitle("Volume Options");
		menu.AddItem("1", "1");
		menu.AddItem("5", "5");
		menu.AddItem("10", "10");
		menu.AddItem("20", "20");
		menu.AddItem("30", "30");
		menu.AddItem("40", "40");
		menu.AddItem("50", "50");
		menu.AddItem("75", "75");
		menu.AddItem("100", "100");
		menu.ExitButton = true;
		menu.Display(client, 30);
	}
	
	return Plugin_Handled;
}

public Action Menu_RadioHelp(client, args)
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client))
	{
		Menu menu = new Menu(HelpMenuHandler);
		menu.SetTitle("Help");
		menu.AddItem("0", "NOTE: You must have HTML MOTD enabled! (cl_disablehtmlmotd 0)", ITEMDRAW_DISABLED);
		menu.AddItem("1", "Type !radio to open up the main menu");
		menu.AddItem("2", "Type !radiohelp to open up this menu");
		menu.AddItem("3", "Type !volume 20 to change the volume. E.G '!volume 25'");
		menu.ExitButton = true;
		menu.Display(client, 30);
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
				
			}
			case 2:
			{
				
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