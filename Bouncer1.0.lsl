//**********************************************
//Title: Car
//Author: 
//Date: 
//**********************************************

//Feel free to modify these basic parameters to suit your needs.
float       forward_power   =   5.2; //Power used to go forward (1 to 30)
float       turning_ratio   =   8.0; //How sharply the vehicle turns. Less is more sharply. (.1 to 10)
vector      movementOffset;
//Anything past this point should only be modfied if you know what you are doing
string      last_wheel_direction;
string      cur_wheel_direction;
integer     cur_level       =   0;
integer     listener;
integer     menuChannel     =   -1976;
integer     chan            =   -12345;
integer     iRLVchan        =   -1812221819;

mainMenu( key id )
{
    list        buttons     = ["Release"];
    // Make sure we close the former listener, so we don't run out of listens.
    llListenRemove( listener );
    listener = llListen(menuChannel, "", id, "");
    llDialog( id, "Please select an option.", buttons, menuChannel );
}

default
{
    state_entry()
    {
        llSetSitText( "Bounce" );
        llSetStatus( STATUS_ROTATE_X | STATUS_ROTATE_Y, TRUE  );
        llSetStatus( STATUS_PHYSICS,                    FALSE );
        llSetLinkAlpha(2,0.0,ALL_SIDES);
        llSetLinkAlpha(3,1.0,ALL_SIDES);
        //car
        llSetVehicleType(       VEHICLE_TYPE_CAR                            );
        llSetVehicleFloatParam( VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY,  0.20);
        llSetVehicleFloatParam( VEHICLE_LINEAR_DEFLECTION_EFFICIENCY,   0.80);
        llSetVehicleFloatParam( VEHICLE_ANGULAR_DEFLECTION_TIMESCALE,   0.10);
        llSetVehicleFloatParam( VEHICLE_LINEAR_DEFLECTION_TIMESCALE,    0.10);
        llSetVehicleFloatParam( VEHICLE_LINEAR_MOTOR_TIMESCALE,         1.0 );
        llSetVehicleFloatParam( VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE,   0.2 );
        llSetVehicleFloatParam( VEHICLE_ANGULAR_MOTOR_TIMESCALE,        0.10);
        llSetVehicleFloatParam( VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE,  0.2 );
        llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE,      <1000.0, 2.0, 1000.0> );
        llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE,     <10.0, 2.0, 1000.0>   );
        llSetVehicleFloatParam( VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.50);
        llSetVehicleFloatParam( VEHICLE_VERTICAL_ATTRACTION_TIMESCALE,  0.50);
    }
    touch_start( integer total_number )
    {
        key         id          =   llDetectedKey( 0 );
        if(id != llGetOwner())
           mainMenu( id );
        else
            llSay( 0, llGetDisplayName(id) + " tries to escape but cant get free" );
    } 
    listen( integer chan, string name, key id, string msg )
    {
        if(msg == "Release")
            llMessageLinked(LINK_ALL_CHILDREN, -12345, "Release", id);
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key agent = llAvatarOnSitTarget();
            if (agent)
            {
                if (agent != llGetOwner())
                {
                                    
                    llMessageLinked( LINK_ALL_CHILDREN, 0, "DRIVING", NULL_KEY );
                    llSleep( .4 );
                    llSetStatus( STATUS_PHYSICS, TRUE );
                    llRequestPermissions(
                        agent,
                        PERMISSION_TRIGGER_ANIMATION    |
                        PERMISSION_TAKE_CONTROLS        |
                        PERMISSION_TRACK_CAMERA
                    );
                    llSetLinkAlpha( 3, 1.0, ALL_SIDES );
                    
                }
                else
                {
                    llMessageLinked( LINK_ALL_CHILDREN, 0, "ON", NULL_KEY );
                    llSetLinkAlpha( 2, 1.0, ALL_SIDES );
                    llSetLinkAlpha( 3, 0.0, ALL_SIDES );
                }
                    
            }
            else
            {
                // Can we release controls when people are no longer sitting?
                llReleaseControls();
                // Don't accept any more menu clicking
                llListenRemove( listener );              
                llSetStatus( STATUS_PHYSICS, FALSE );
                llSleep( .1 );
                llMessageLinked( LINK_ALL_CHILDREN, 0, "STAND", NULL_KEY );
                llMessageLinked( LINK_ALL_CHILDREN, 0, "OFF",   NULL_KEY );
            }
        }
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
            llTakeControls(
                CONTROL_FWD         |
                CONTROL_BACK        |
                CONTROL_DOWN        |
                CONTROL_UP          |
                CONTROL_RIGHT       |
                CONTROL_LEFT        |
                CONTROL_ROT_RIGHT   |
                CONTROL_ROT_LEFT,
                TRUE,
                FALSE
            );
    }
    control(key id, integer level, integer edge)
    {
        integer     reverse             =   1;
        vector      angular_velocity    =   <0,0,  70 * DEG_TO_RAD>;
        movementOffset                  =   <0,0,0>;
        vector      eul                 =   llRot2Euler(llGetCameraRot() / llGetRot());
        rotation    face                =   llEuler2Rot(<0,0,eul.z>);
        //get current speed
        vector      vel                 =   llGetVel();
        float       speed               =   llVecMag(vel);
        integer     new_level           =   0;
        //car controls
        // If we do forward, don't do backwards.
        if (level & CONTROL_FWD)
        {
            new_level                   =   CONTROL_FWD;
            reverse                     =   1;
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <forward_power,0,0> );
        }
        else
        if (level & CONTROL_BACK)
        {
            new_level                   =   CONTROL_BACK;
            reverse                     =   -1;
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <-1*forward_power,0,0> );
        }
        if(level & (CONTROL_RIGHT|CONTROL_ROT_RIGHT))
        {
            new_level                   =   CONTROL_RIGHT;
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_velocity * -1 );
        }
        if(level & (CONTROL_LEFT|CONTROL_ROT_LEFT))
        {
            new_level                   =   CONTROL_LEFT;
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_velocity );
        }
        // No controls touched?
        // 0 is out default for new_level, meaning no flags.
        if ( new_level != cur_level )
        {
            cur_level                   =   new_level;
            llMessageLinked(LINK_ALL_CHILDREN, 12345, cur_level, NULL_KEY);
        }
    }
}
