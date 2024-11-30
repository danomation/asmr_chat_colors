#include <sourcemod>
#include <sdktools>

public Plugin myinfo =
{
        name = "ASMR Chat Colors",
        author = "SEA.LEVEL.RISESâ„¢",
        description = "Stay golden.",
        version = "0.3",
        url = "v54.io"
}


static char Steam3ClientsOfInterest[][][] = {
// add users here format { "[STEAMID3]", "color as RRGGBB" },

};

// TODO: gamma adjust by 2.2
static char g_sPunksChatFormat[] = "\x08ff3d3d%N\x01: \x08%s%s\x0a";
static char g_sCorpsChatFormat[] = "\x084a7eff%N\x01: \x08%s%s\x0a";

static int g_iPlayersWithColors[MAXPLAYERS];
static char g_sPlayerColors[MAXPLAYERS][7];

static char ThankYouMessages[][] = {
        // "\x04You like swag? \x08ffd700We got swag! \x083498dbv54.io/swag\x01",
        // "\x08ffd700New swag available! \x083498dbv54.io/swag\x01",
        // "\x04Thank you for your support! \x083498dbv54.io\x01",
        "\x08ffd700This server is proudly sponsored by your fellow players. \x04Thank you for your support!\x01",
        "\x08ffd700Wintermute has granted you potato access\x01",
        "\x08FFC5FEJoin Wintermute Discord - \x083498DBhttps://switchmeme.com/discord\x01",
        "\x083498DBp o t a t o\x083498db\x01",
};

public void OnPluginStart() {
        int client = MaxClients;

        while ( client ) {

                if ( IsClientAuthorized(client) ) {
                        char auth[64];
                        GetClientAuthId( client, AuthId_Steam3, auth, sizeof(auth)-1 );

                        for ( int j = 0; j < sizeof(Steam3ClientsOfInterest); j++ ) {
                                if ( 0 == strcmp( Steam3ClientsOfInterest[j][0], auth, false ) ) {
                                        g_iPlayersWithColors[client] = 1;
                                        strcopy( g_sPlayerColors[client], 7, Steam3ClientsOfInterest[j][1] );
                                        continue;
                                }
                        }
                }

                client--;
        }
}

public void OnClientPutInServer( int client ) {
        if ( IsFakeClient(client) ) {
                return;
        }

        CreateTimer( 10.0, Timer_ThankYouMessage, client, TIMER_FLAG_NO_MAPCHANGE );
}

Action Timer_ThankYouMessage( Handle timer, int client ) {
        PrintToChat(
                client,
                ThankYouMessages[GetRandomInt( 0, sizeof(ThankYouMessages)-1 )]
        );

        return Plugin_Stop;
}


public void OnClientPostAdminCheck( int client ) {
        if ( IsFakeClient(client) ) {
                return;
        }

        char auth[64];
        GetClientAuthId( client, AuthId_Steam3, auth, sizeof(auth)-1 );

        for ( int j = 0; j < sizeof(Steam3ClientsOfInterest); j++ ) {
                if ( 0 == strcmp( Steam3ClientsOfInterest[j][0], auth, false ) ) {
                        g_iPlayersWithColors[client] = 1;
                        strcopy( g_sPlayerColors[client], 7, Steam3ClientsOfInterest[j][1] );
                        break;
                }
        }
}

public void OnClientDisconnect( int client ) {
        g_iPlayersWithColors[client] = 0;
}

public Action OnClientSayCommand( int client, const char[] command, const char[] sArgs ) {
        if ( 0 != strcmp( "say", command, false ) ) {
                return Plugin_Continue;
        }

        if ( !g_iPlayersWithColors[client] ) {
                return Plugin_Continue;
        }

        int iClientTeam = GetEntProp( client, Prop_Data, "m_iTeamNum" );
        switch ( iClientTeam ) {
                case 2: {
                        PrintToChatAll(
                                g_sPunksChatFormat,
                                client,
                                g_sPlayerColors[client],
                                sArgs
                        );
                        return Plugin_Handled;
                }
                case 3: {
                        PrintToChatAll(
                                g_sCorpsChatFormat,
                                client,
                                g_sPlayerColors[client],
                                sArgs
                        );
                        return Plugin_Handled;
                }
        }

        return Plugin_Continue;
}
