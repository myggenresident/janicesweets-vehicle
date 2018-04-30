//**********************************************
//Title: Car
//Author: 
//Date: 
//**********************************************

//Feel free to modify these basic parameters to suit your needs.
float forward_power = 5.2; //Power used to go forward (1 to 30)
float reverse_power = -5.2; //Power ued to go reverse (-1 to -30)
float turning_ratio = 8.0; //How sharply the vehicle turns. Less is more sharply. (.1 to 10)
string sit_message = "Bounce"; //Sit message
vector movementOffset;
//Anything past this point should only be modfied if you know what you are doing
string last_wheel_direction;
string cur_wheel_direction;
key agent;
integer listener;
integer menuChannel = -1976;
integer chan = -12345;
key id;
integer iChan =-1812221819;

integer  iDialogChannel     = 0;
integer  iListenHandle      = 0;

mainMenu(key id)
{
    list buttons;
    if(llDetectedKey(0))
    {
        buttons += ["Release"];
        
       
    }
    string prompt = "Please select an option.";
    listener = llListen(menuChannel, "", id, "");
    llDialog(id, prompt, buttons, menuChannel);
}


default
{
    state_entry()
    {
        llSetSitText(sit_message);
        llSetStatus( STATUS_ROTATE_X | STATUS_ROTATE_Y, TRUE);
        
        
        llSetLinkAlpha(2,0.0,ALL_SIDES);
        llSetLinkAlpha(3,1.0,ALL_SIDES);
        
        //car
         llSetVehicleType(VEHICLE_TYPE_CAR);
         llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_EFFICIENCY, 0.20);
         llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_EFFICIENCY, 0.80);
         llSetVehicleFloatParam(VEHICLE_ANGULAR_DEFLECTION_TIMESCALE, 0.10);
         llSetVehicleFloatParam(VEHICLE_LINEAR_DEFLECTION_TIMESCALE, 0.10);
         llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_TIMESCALE, 1.0);
         llSetVehicleFloatParam(VEHICLE_LINEAR_MOTOR_DECAY_TIMESCALE, 0.2);
         llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_TIMESCALE, 0.10);
         llSetVehicleFloatParam(VEHICLE_ANGULAR_MOTOR_DECAY_TIMESCALE, 0.2);
         llSetVehicleVectorParam(VEHICLE_LINEAR_FRICTION_TIMESCALE, <1000.0, 2.0, 1000.0> );
         llSetVehicleVectorParam(VEHICLE_ANGULAR_FRICTION_TIMESCALE, <10.0, 2.0, 1000.0> );
         llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_EFFICIENCY, 0.50);
         llSetVehicleFloatParam(VEHICLE_VERTICAL_ATTRACTION_TIMESCALE, 0.50);
         
         
      
    }

    touch_start(integer total_number)
    {
        if(llDetectedKey(0) != llGetOwner())
        {
           mainMenu(llDetectedKey(0));
                
            
        }
        else
        {
            llSay(0,llGetDisplayName(llDetectedOwner(0)) + " Tries To escape but cant get free");
        }
    } 

listen(integer chan, string name, key id, string msg)
    {
        
        if(msg == "Release")
        {
            llSay(-12345,"Release");
            llRegionSayTo(llDetectedOwner(0),iChan, "ClearRLV," + (string)llGetOwner() + ",@clear");
            llOwnerSay("@clear");
            llRegionSayTo(llGetOwner(),iChan, "ClearRLV," + (string)llGetOwner() + "!release");
            llSleep(0.5);
            llRegionSayTo(llGetOwner(),iChan, "ForceUnSit," + (string)llGetOwner() + ",@unsit=force");
            llSleep(2.0);
           // llDie();
            
        }
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
                                    
                    llMessageLinked(LINK_ALL_CHILDREN , 0,"DRIVING", NULL_KEY);
                    llSleep(.4);
                    llSetStatus(STATUS_PHYSICS, TRUE);
                    llSleep(.1);
                    llRequestPermissions(agent, PERMISSION_TRIGGER_ANIMATION | PERMISSION_TAKE_CONTROLS |PERMISSION_TRACK_CAMERA);
                    llGetPermissions();
                    llSetTimerEvent(0.1);
                    llSetLinkAlpha(3,1.0,ALL_SIDES);
                    
                }
                 
                if (agent == llGetOwner())
                {
                     llMessageLinked(LINK_ALL_CHILDREN , 0,"ON", NULL_KEY);
                     llSetLinkAlpha(2,1.0,ALL_SIDES);
                     llSetLinkAlpha(3,0.0,ALL_SIDES);
                    }
                    
            }
            else
            {
                llSetTimerEvent(0);
             
                llSetStatus(STATUS_PHYSICS, FALSE);
                llSleep(.1);
                llMessageLinked(LINK_ALL_CHILDREN , 0, "STAND", NULL_KEY);
                llMessageLinked(LINK_ALL_CHILDREN , 0,"OFF", NULL_KEY);
                llSleep(.4);
                llReleaseControls();
                
                llListenRemove(iListenHandle);
                llListenRemove(listener);              
                llResetScript();
            }
         }
    }
        

    
    run_time_permissions(integer perm)
    {
        if (perm)
        {
            llTakeControls(CONTROL_FWD | CONTROL_BACK | CONTROL_DOWN | CONTROL_UP | CONTROL_RIGHT | 
                            CONTROL_LEFT | CONTROL_ROT_RIGHT | CONTROL_ROT_LEFT, TRUE, FALSE);
        }
    }
    
    control(key id, integer level, integer edge)
    {
        integer reverse=1;
        vector angular_velocity = <0,0, 70 * DEG_TO_RAD>;
        vector angular_velocity1 = <0,0, -70 * DEG_TO_RAD>;
        vector angular_motor;
        movementOffset = <0,0,0>;
        vector eul = llRot2Euler(llGetCameraRot() / llGetRot());
        rotation face = llEuler2Rot(<0,0,eul.z>);
        
        //get current speed
        vector vel = llGetVel();
        float speed = llVecMag(vel);

        //car controls
        if(level & CONTROL_FWD)
        {
            cur_wheel_direction = "DRIVING";
            llSay(chan, "walk");
             llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <forward_power,0,0> );
            reverse=1;
        }
        if(level & CONTROL_BACK)
        {
            cur_wheel_direction = "DRIVING";
            llSay(chan, "walk");
             llSetVehicleVectorParam(VEHICLE_LINEAR_MOTOR_DIRECTION, <reverse_power,0,0> );
            reverse = -1;
        }

        if(level & (CONTROL_RIGHT|CONTROL_ROT_RIGHT))
        {
            cur_wheel_direction = "RIGHT";
            llSay(chan, "right");
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_velocity1);
        }
        
        
        if(level & (CONTROL_LEFT|CONTROL_ROT_LEFT))
        {
            cur_wheel_direction = "LEFT";
            llSay(chan, "left");
            llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_velocity);
        }
        if(level & FALSE)
        {
            
            cur_wheel_direction = "STAND";
             // llSetVehicleVectorParam(VEHICLE_ANGULAR_MOTOR_DIRECTION, angular_motor);
        }

    } //end control   
    
    
  

    timer()
    {
        if (cur_wheel_direction != last_wheel_direction)
        {
            llMessageLinked(LINK_ALL_CHILDREN , 0, cur_wheel_direction, NULL_KEY);
            last_wheel_direction = cur_wheel_direction;
        }
    }
    
} //end default
