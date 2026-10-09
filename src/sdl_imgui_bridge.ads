with Interfaces.C;
with Interfaces.C.Strings;

package SDL_Imgui_Bridge is
   function Initialise return Interfaces.C.int
     with Import, Convention => C, External_Name => "bridge_init";
   function Poll return Interfaces.C.int
     with Import, Convention => C, External_Name => "bridge_poll";
   procedure New_Frame
     with Import, Convention => C, External_Name => "bridge_new_frame";
   function Present return Interfaces.C.int
     with Import, Convention => C, External_Name => "bridge_present";
   procedure Shutdown
     with Import, Convention => C, External_Name => "bridge_shutdown";
   function Error return Interfaces.C.Strings.chars_ptr
     with Import, Convention => C, External_Name => "bridge_error";
end SDL_Imgui_Bridge;
