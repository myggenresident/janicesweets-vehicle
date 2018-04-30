float       forward_power   =   5.2; //Power used to go forward (1 to 30)
string      cur_level;
integer     listener;
integer     menuChannel     =   -1976;
key         driver          =   NULL_KEY;

mainMenu( key id )
{
    llListenRemove( listener );
    listener = llListen(menuChannel, "", id, "");
    llDialog( id, "Please select an option.", ["Release"], menuChannel );
}

send_level( string new_level )
{
    if ( new_level != cur_level )
    {
        cur_level                   =   new_level;
        llMessageLinked(LINK_ALL_CHILDREN, 0, cur_level, NULL_KEY);
    }
}

default
{
    state_entry()
    {
        cur_level = "";
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
    on_rez( integer i )
    {
        driver = NULL_KEY;
        llSetStatus( STATUS_PHYSICS,                    FALSE );
    }
    touch_start( integer i )
    {
        while (i-- > 0 )
        {
            key     id                  =   llDetectedKey( i );
            if( id == llGetOwner() )
                llSay( 0, llGetDisplayName(id) + " tries to escape but cant get free" );
            else
            if ( id == driver )
                mainMenu( id );
        }
    } 
    listen( integer chan, string name, key id, string msg )
    {
        // Menu returned with this command.
        if ( msg == "Release" )
            llMessageLinked(LINK_ALL_CHILDREN, 0, "Release", id);
    }
    run_time_permissions(integer perm)
    {
        if (perm & PERMISSION_TAKE_CONTROLS)
            llTakeControls(
                CONTROL_FWD         |
                CONTROL_BACK        |
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
        //car controls
        integer     reverse             =   1;
        vector      angular_velocity    =   <0,0,  70 * DEG_TO_RAD>;
        // STAND is our default for new_level, meaning no controls touched.
        string      new_level           =   "STAND";
        // If we do forward, don't do backwards.
        if (level & CONTROL_FWD)
        {
            new_level                   =   (string)CONTROL_FWD;
            reverse                     =   1;
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <forward_power,0,0> );
        }
        else
        if (level & CONTROL_BACK)
        {
            new_level                   =   (string)CONTROL_BACK;
            reverse                     =   -1;
            llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <-1*forward_power,0,0> );
        }
        if(level & (CONTROL_RIGHT|CONTROL_ROT_RIGHT))
        {
            new_level                   =   (string)CONTROL_RIGHT;
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_velocity * -1 );
        }
        if(level & (CONTROL_LEFT|CONTROL_ROT_LEFT))
        {
            new_level                   =   (string)CONTROL_LEFT;
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_velocity );
        }
        send_level( new_level );
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        if ( str == "Driver" )
        {
            driver      =   id;
            send_level( "STAND" );
            if ( id )
            {
                if (driver != llGetOwner())
                    llSetLinkAlpha( 3, 1.0, ALL_SIDES );
                else
                {
                    // When owner sits
                    llSetLinkAlpha( 2, 1.0, ALL_SIDES );
                    llSetLinkAlpha( 3, 0.0, ALL_SIDES );
                }
                llSetStatus( STATUS_PHYSICS, TRUE );
                // Only take controls of the driver
                llRequestPermissions(
                    driver,
                    PERMISSION_TAKE_CONTROLS        |
                    PERMISSION_TRACK_CAMERA
                );
            }
            else
            {
                // Driver gets up, so we will no longer be moving.
                llSetStatus( STATUS_PHYSICS, FALSE );
                // Can we release controls when people are no longer sitting?
                llReleaseControls();
                // Don't accept any more menu clicking
                llListenRemove( listener );              
            }
        }
    }
}
