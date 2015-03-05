-- Alba Guardado Garcia

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;

package Image_EP is --CAMBIAR POR PACKAGE BODY

	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	

	function Image (EP: LLU.End_Point_Type) return String ;

end Image_EP;
