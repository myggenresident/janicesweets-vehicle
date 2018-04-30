key kAgent;
key kAv;
string sBounce = "Bounce Stand" ;
string sBLeft  = "Bounce Left" ;
string sBRight = "Bounce Right" ;
string sBForw  = "Bounce Forward" ;

integer iChan =-1812221819;

integer  iDialogChannel     = 0;
integer  iListenHandle      = 0;
string sCommand = "forceSit,"; //arbitrary name, useful at times so you can identify commands
string victim;
string anim_new;
string anim_old;
string sAnim;
integer iAnimTime = 1;
integer listener;
integer menuChannel = -1976;
integer chan = -12345;
key id;

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

animateperms()
{
    
    integer count = llGetInventoryNumber(INVENTORY_ANIMATION);
    llGetInventoryName(INVENTORY_ANIMATION,count - 1);
    llRequestPermissions(llAvatarOnSitTarget(),PERMISSION_TRIGGER_ANIMATION);
    llGetPermissions();
    llStopAnimation("sit");
}

victim1()
{
    llDetectedOwner(0);
}
default
{
    state_entry()
    {
        llSetCameraEyeOffset(<-2.0, 0.0, 2.0> );
        llSetCameraAtOffset(<4.0, 0.0, 2.0> );
        llSitTarget(<0.15,0.0,0.01>, ZERO_ROTATION);
        //animateperms();
        iListenHandle = llListen( iChan, "", llGetOwner(), "");
        listener = llListen(chan, "", NULL_KEY,"");
        key kPrisoner = llGetOwner();
        
    }
    on_rez(integer num)
    {
        key kPrisoner = llGetOwner();
        llRegionSayTo(llGetOwner(),iChan, "ForceSit," + (string)llGetOwner() + ",@sit:" +
        (string)llGetKey() + "=force");
        llRegionSayTo(llGetOwner(),iChan, "DenyStand," + (string)llGetOwner() + ",@unsit=n");
        //animateperms();
    }
    
     changed(integer change)
    {
        if (change & CHANGED_LINK)
        {
            key newav = llAvatarOnSitTarget();
            if (newav != NULL_KEY)
            {
                key newav = llAvatarOnSitTarget();
           
                string snewav = llAvatarOnSitTarget();
                integer count = llGetInventoryNumber(INVENTORY_ANIMATION);
                sAnim=llGetInventoryName(INVENTORY_ANIMATION,count - 1);
                llRequestPermissions(newav, PERMISSION_TRIGGER_ANIMATION);
                llGetPermissions();
                llSay(iChan,"AcceptPerms" + (string) snewav + ("@acceptpermissions=y"));
                llStopAnimation("sit");
                llStartAnimation(sBounce);
                llListenRemove(iListenHandle);
            }
            else
            {
                vector agent2 = llGetAgentSize((key)kAv);
                if(agent2)
                {
                    llStopAnimation(anim_new);
                }
                kAv = NULL_KEY;
                
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
            llStartAnimation(sBForw);
        }
        if(str == "STAND")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
            llStartAnimation(sBounce);
        }
        if(str == "LEFT")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
           
            llStartAnimation(sBounce);
        }
        if(str == "RIGHT")
        {
            llSleep(iAnimTime);
            llStopAnimation(anim_new);
           
            llStartAnimation(sBounce);
        }
                                                      
    }
        



   
    listen(integer chan, string name, key kID, string msg )
    {
        
        if(chan)
        {
            if(msg == "Release")
            {
                llSay(0,"you are released");
                llSay(iChan, "ClearRLV," + (string)llGetOwner() + ",@clear");
                llSay(iChan, "ClearRLV," + (string)llGetOwner() + ",!release");
                llSleep(0.5);
                llSay(iChan, "ForceUnSit," + (string)llGetOwner() + ",@unsit=force");
                llSleep(2.0);
           // llDie();
            }
            if(msg == "walk")
            {
                llSleep(iAnimTime);
                llStopAnimation(anim_new);
           
                llStartAnimation(sBForw);
            }
            if(msg == "left")
            {
                llSleep(iAnimTime);
                llStopAnimation(anim_new);
           
                llStartAnimation(sBLeft);
            }
            if(msg == "right")
            {
                llSleep(iAnimTime);
                llStopAnimation(anim_new);
           
                llStartAnimation(sBRight);
            }
            else
            {
                llSleep(iAnimTime);
                llStopAnimation(anim_new);
                llStartAnimation(sBounce);
            }
        }
        
       
       
    }


run_time_permissions(integer perm)
    {
        
        if (perm == PERMISSION_TAKE_CONTROLS)
        {
            llTakeControls( CONTROL_FWD | CONTROL_BACK | CONTROL_ROT_LEFT | CONTROL_ROT_RIGHT | CONTROL_UP | CONTROL_DOWN | CONTROL_LEFT | CONTROL_RIGHT, TRUE,TRUE);
           
                
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
