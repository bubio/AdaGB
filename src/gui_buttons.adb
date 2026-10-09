with Interfaces.C;
with Interfaces.C.Strings;

package body Gui_Buttons is
   use type Interfaces.C.unsigned_char;

   --  cimgui takes ImVec2 by value, not as a pointer. Convention C alone
   --  on df_imgui's record causes GNAT to pass it by reference to C.
   type Vec2 is record
      X, Y : Interfaces.C.C_float;
   end record with Convention => C_Pass_By_Copy;

   function C_Button
     (Label : Interfaces.C.Strings.chars_ptr;
      Size : Vec2) return Interfaces.C.unsigned_char
     with Import, Convention => C, External_Name => "igButton";

   function Button (Label : String) return Boolean is
      C_Label : Interfaces.C.Strings.chars_ptr :=
        Interfaces.C.Strings.New_String (Label);
      Clicked : constant Interfaces.C.unsigned_char :=
        C_Button (C_Label, (0.0, 0.0));
   begin
      Interfaces.C.Strings.Free (C_Label);
      return Clicked /= 0;
   end Button;
end Gui_Buttons;
