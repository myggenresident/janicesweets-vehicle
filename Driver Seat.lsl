string      sRBounce            =   "Rider Sit" ;
string      sRLeft              =   "Rider Left" ;
string      sRRight             =   "Rider Right" ;
string      sRForw              =   "Rider Forward" ;

integer     iChan               =   -1812221819;

integer     iDialogChannel      =   0;
integer     iListenHandle       =   0;
string      anim_new;
string      anim_old;
string      sAnim;
integer     iAnimTime           =   1;
key         kAgent              =   NULL_KEY;
integer     listener;
integer     listener2;
integer     menuChannel         =   -1976;
integer     chan                =   -12345;
key         id;

mainMenu(key id)
{
    list buttons;
    if(llDetectedKey(0))
        buttons += ["Release"];
    string prompt = "Please select an option.";
    listener = llListen(menuChannel, "", id, "");
    listener2 = llListen(chan, "",id,"");
    llDialog(id, prompt, buttons, menuChannel);
}

animateperms()
{
    integer     count           =   llGetInventoryNumber(INVENTORY_ANIMATION);
    llGetInventoryName(INVENTORY_ANIMATION,count - 1);
    llRequestPermissions(llAvatarOnSitTarget(),PERMISSION_TRIGGER_ANIMATION|PERMISSION_TRACK_CAMERA);
    llGetPermissions();
    llStopAnimation("sit");
}

default
{
    state_entry()
    {
        llSetCameraEyeOffset(<-2.0, 0.0, 2.0> );
        llSetCameraAtOffset(<4.0, 0.0, 2.0> );
        llSitTarget(<0.0,0,0.75>, ZERO_ROTATION);
        llSetTimerEvent(0.0);
        key     kPrisoner       =   llAvatarOnSitTarget();
    }
    touch_start(integer total_number)
    {
        key     kPrisoner       =   llAvatarOnSitTarget();
        if(kPrisoner != llGetOwner())
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
            llRegionSayTo(llGetOwner(),iChan, "ClearRLV," + (string)llGetOwner() + ",@clear");
            llSleep(0.5);
            llRegionSayTo(llGetOwner(),iChan, "ForceUnSit," + (string)llGetOwner() + ",@unsit=force");
            llSleep(2.0);
           // llDie();
        }
        if(msg == "walk")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRForw);
        }
        if(msg == "left")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRLeft);
        }
        if(msg == "right")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRRight);
        }
        else
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRBounce);
        }
    }
    changed(integer change)
    {
        if (change & CHANGED_LINK) 
        {
            key newav = llAvatarOnSitTarget();
            if (newav != NULL_KEY)
            {
                llResetScript();
                key         newav       =   llAvatarOnSitTarget();
                string      snewav      =   llAvatarOnSitTarget();
                integer     count       =   llGetInventoryNumber(INVENTORY_ANIMATION);
                sAnim                   =   llGetInventoryName(INVENTORY_ANIMATION,count - 1);
                llRequestPermissions(newav, PERMISSION_TRIGGER_ANIMATION);
                llGetPermissions();
                llRegionSayTo(llGetOwner(),iChan,"AcceptPerms" + (string) snewav + ("@acceptpermissions=y"));
                llStopAnimation("sit");
                llStartAnimation(sRBounce);
                llListenRemove(iListenHandle);
            }
            else
            {
                vector      agent2      =   llGetAgentSize((key)newav);
                if(agent2)
                    llStopAnimation(anim_new);
                newav = NULL_KEY;  
                llListenRemove(iListenHandle);
                llListenRemove(listener);
            }            
        }
    }
    link_message(integer sender_num, integer num, string str, key id)
    {
        
        if(str == "DRIVING")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRForw);
        }
        if(str == "STAND")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRBounce);
        }
        if(str == "LEFT")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRLeft);
        }
        if(str == "RIGHT")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sRRight);
        }
                                                      
    }
    on_rez(integer iNum)
    {
             llResetScript();
    }
    run_time_permissions(integer perm)
    {
        animateperms();
        if (perm == PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls(
                CONTROL_FWD         |
                CONTROL_BACK        |
                CONTROL_ROT_LEFT    |
                CONTROL_ROT_RIGHT   |
                CONTROL_UP          |
                CONTROL_DOWN        |
                CONTROL_LEFT        |
                CONTROL_RIGHT,
                TRUE,
                TRUE
            );
        }
        else
        {
            animateperms();
        }
    }
    timer()
    {
        if (anim_new != anim_old)
        {
            llStopAnimation(anim_old);
            llStartAnimation(anim_new);
            anim_old = anim_new;
        }
    }
}
