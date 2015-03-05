-- Alba Guardado Garcia

with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Command_Line;

package body Image_EP is 


	use type ASU.Unbounded_String;

	function Image (EP: LLU.End_Point_Type) return String is
		Longitud: Natural;
		Cadena: ASU.Unbounded_String;
		Longitud_Parte_1: Natural;
		Cadena_Final: ASU.Unbounded_String;
		Cadena_Nula: String:= "null";
		
		IP: ASU.Unbounded_String;
		Puerto: ASU.Unbounded_String;
	begin
		Cadena:= ASU.To_Unbounded_String(LLU.Image(EP));
		
		if Cadena = "null" then
			return Cadena_Nula;
			
		else
			Longitud:= ASU.Length(Cadena);
			Longitud_Parte_1 := ASU.Index (Cadena, "IP");
			
			Cadena:= ASU.Tail (Cadena, Longitud - Longitud_Parte_1 + 1);
			
			--IP: 127.0.1.1, Port:  55523
			Longitud:= ASU.Length(Cadena);
			Longitud_Parte_1 := ASU.Index (Cadena, " ");
			
			Cadena:= ASU.Tail (Cadena, Longitud - Longitud_Parte_1);
			
			--127.0.1.1, Port:  55523
			Longitud:= ASU.Length(Cadena);
			Longitud_Parte_1 := ASU.Index (Cadena, "P");
			
			IP:= ASU.Head(Cadena,  Longitud_Parte_1 - 3); 
			
			--127.0.1.1
			Longitud:= ASU.Length(Cadena);
			Longitud_Parte_1 := ASU.Index (Cadena, ": ");
			
			Puerto:= ASU.Tail (Cadena, Longitud - Longitud_Parte_1 - 1);
			
			--  55523
			Cadena_Final:= "(" & IP & ":" & Puerto & ")";
			
			return ASU.To_String(Cadena_Final);
		end if;
	end;

end Image_EP;
