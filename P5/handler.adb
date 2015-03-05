-- Alba Guardado Garcia

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Chat_Messages;
with Seq_N_T;
with Ada.Command_Line;
with Pantalla;
with Debug;
with Ada.Calendar;
with Timed_Handlers;
with Ada.Unchecked_Deallocation;

package body Handler is 

	--LOS RENAMES QUE ESTAN EN EL ADS VALEN TB PARA EL ADB
	
	use type Seq.Seq_N_T;
	use type CM.Message_Type;
	use type ASU.Unbounded_String;
	use type LLU.End_Point_Type;
	use type Ada.Calendar.Time;
	
	procedure Free is new Ada.Unchecked_Deallocation (LLU.Buffer_Type, CM.Buffer_A_T);
	
	procedure Recibo_Init (	P_Buffer: access LLU.Buffer_Type; Nick: in out ASU.Unbounded_String; Seq_N: in out Seq.Seq_N_T; 
									EP_H_Creat: in out LLU.End_Point_Type; EP_H_Rsnd: in out LLU.End_Point_Type;
									EP_R_Creat: in out LLU.End_Point_Type) is
		
	begin
		EP_H_Creat := LLU.End_Point_Type'Input (P_Buffer);
		Seq_N := Seq.Seq_N_T'Input (P_Buffer);
		EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer);
		EP_R_Creat := LLU.End_Point_Type'Input (P_Buffer);
		Nick := ASU.Unbounded_String'Input (P_Buffer);
	end Recibo_Init;
	
	
	procedure Recibo_Confirm (	P_Buffer: access LLU.Buffer_Type; EP_H_Creat: in out LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T;
										EP_H_Rsnd: in out LLU.End_Point_Type; Nick: in out ASU.Unbounded_String) is
	begin
		EP_H_Creat := LLU.End_Point_Type'Input (P_Buffer);
		Seq_N := Seq.Seq_N_T'Input (P_Buffer);
		EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer);
		Nick := ASU.Unbounded_String'Input (P_Buffer);
	end Recibo_Confirm;
	
	
	procedure Recibo_Logout (	P_Buffer: access LLU.Buffer_Type; EP_H_Creat: in out LLU.End_Point_Type;
										Seq_N: in out Seq.Seq_N_T; EP_H_Rsnd: in out LLU.End_Point_Type; 
										Nick: in out ASU.Unbounded_String; Confirm_Sent: in out Boolean) is
	begin
		EP_H_Creat := LLU.End_Point_Type'Input (P_Buffer);
		Seq_N := Seq.Seq_N_T'Input (P_Buffer);
		EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer);
		Nick := ASU.Unbounded_String'Input (P_Buffer);
		Confirm_Sent:= Boolean'Input (P_Buffer);
	end Recibo_Logout;
	
	
	procedure Recibo_Writer (	P_Buffer: access LLU.Buffer_Type; EP_H_Creat: in out LLU.End_Point_Type;
										Seq_N: in out Seq.Seq_N_T; EP_H_Rsnd: in out LLU.End_Point_Type; 
										Nick: in out ASU.Unbounded_String; Texto: in out ASU.Unbounded_String) is
	begin
		EP_H_Creat := LLU.End_Point_Type'Input (P_Buffer);
		Seq_N := Seq.Seq_N_T'Input (P_Buffer);
		EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer);
		Nick := ASU.Unbounded_String'Input (P_Buffer);
		Texto:= ASU.Unbounded_String'Input (P_Buffer);
	end Recibo_Writer;
	
	
	procedure Envio_Por_Inundacion ( P_Buffer: access LLU.Buffer_Type; 
												Array_EP: in out Handler.Neighbor.Keys_Array_Type; 
												Longitud_Lista: in out Natural; EP_H_Rsnd: in out LLU.End_Point_Type;
												Condicion_Envio: in out Boolean; Value_Sender_Dests: in out Othrs.Destinations_T) is
	begin
		Array_EP:= Handler.Neighbor.Get_Keys (Handler.My_Neighs);
		Longitud_Lista:= Handler.Neighbor.Map_Length(Handler.My_Neighs);
		
		for k in 1..Longitud_Lista loop
		
			if (Array_EP(k) /= EP_H_Rsnd) then
				Condicion_Envio:= True;
				LLU.Send(Array_EP(k), P_Buffer);
				Value_Sender_Dests(k).EP:= Array_EP(k);
				Debug.Put_Line(Image_EP.Image(EP_H_Rsnd) & " send to " & Image_EP.Image(Array_EP(k)), Pantalla.Verde); 
			end if;
		end loop;
	end Envio_Por_Inundacion;
	
	
	procedure Put_Sender_Buffering (	P_Buffer: CM.Buffer_A_T;  Plazo_Retransmision: in out Duration; 
												Hora_Retransmision: in out Ada.Calendar.Time; EP_H_Creat: LLU.End_Point_Type;
												Seq_N: in out Seq.Seq_N_T) is
		Value_Sender_Buffering: Othrs.Value_T;
	begin
		Plazo_Retransmision:= 2 * Duration(Integer'Value(Ada.Command_Line.Argument(4))) / 1000;------------- PONER MAS BONITO
		Hora_Retransmision:= Ada.Calendar.Clock + Plazo_Retransmision;
		
		Value_Sender_Buffering.EP_H_Creat:= EP_H_Creat;
		Value_Sender_Buffering.Seq_N:= Seq_N;
		Value_Sender_Buffering.P_Buffer:= P_Buffer;
		
		Handler.Sender_Buffering.Put(Handler.My_SB_Map, Hora_Retransmision, Value_Sender_Buffering);
		Debug.Put_Line("Añadimos a sender buffering " & Handler.C_Image.Image_1(Hora_Retransmision) & " | "&
							Othrs.Value_T_To_String(Value_Sender_Buffering), Pantalla.Verde);
	end Put_Sender_Buffering;


	procedure Put_Sender_Dests (Key_Sender_Dests: in out Othrs.Mess_Id_T ; Value_Sender_Dests: in out Othrs.Destinations_T;
										EP_H_Creat: LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T) is
	begin
		Key_Sender_Dests.EP:= EP_H_Creat;
		Key_Sender_Dests.NSeq:= Seq_N;
		
		Handler.Sender_Dests.Put(Handler.My_SD_Map, Key_Sender_Dests, Value_Sender_Dests);
		Debug.Put_Line("Añadimos a sender dests " & Othrs.Mess_Id_T_To_String(Key_Sender_Dests) & " | "&
						Othrs.Destinations_T_To_String(Value_Sender_Dests), Pantalla.Verde);
	end Put_Sender_Dests;
	
	
	procedure Envio_Ack (P_Buffer: access LLU.Buffer_Type; EP_Handler_Nodo: in out LLU.End_Point_Type;
								EP_H_Creat: in out LLU.End_Point_Type; Seq_N: in out Seq.Seq_N_T; 
								Mess: in out CM.Message_Type; EP_H_Envio: in out LLU.End_Point_Type) is
	begin
		Mess:= CM.Ack;
		LLU.Reset(P_Buffer.all);
		
		CM.Message_Type'Output(P_Buffer, Mess);
		LLU.End_Point_Type'Output(P_Buffer, EP_Handler_Nodo); --del nodo que envia el mensaje
		LLU.End_Point_Type'Output(P_Buffer, EP_H_Creat);
		Seq.Seq_N_T'Output(P_Buffer, Seq_N);
		
		LLU.Send(EP_H_Envio, P_Buffer); -- Me da aqui el error
		Debug.Put("ENVIO ACK (EP_H_Creat) " & Image_EP.Image(EP_H_Creat) & "send to " & Image_EP.Image(EP_H_Envio), Pantalla.Azul_Claro);
	end Envio_Ack;
	
	
	procedure Retransmisiones (Hora_Retransmision: in  Ada.Calendar.Time) is
		Value_Sender_Buffering: Othrs.Value_T;
		Success: Boolean:= False;
		Key_Sender_Dests: Othrs.Mess_Id_T;
		Value_Sender_Dests: Othrs.Destinations_T;
		Array_No_Nulo: Boolean:= False;
		Nueva_Hora_Retransmision: Ada.Calendar.Time;
		Plazo_Retransmision: Duration;
	begin
		Handler.Sender_Buffering.Get(Handler.My_SB_Map, Hora_Retransmision, Value_Sender_Buffering, Success);
		
		if Success = True then --si esa clave esta en mi sender_buffering
			Handler.Sender_Buffering.Delete(Handler.My_SB_Map, Hora_Retransmision, Success);
			
			Key_Sender_Dests.EP:= Value_Sender_Buffering.EP_H_Creat;
			Key_Sender_Dests.Nseq:= Value_Sender_Buffering.Seq_N;
			
			Handler.Sender_Dests.Get(Handler.My_SD_Map, Key_Sender_Dests, Value_Sender_Dests, Success);-- ahora tengo en value dests el array destinations_T
			if Success /= False then -- Sender Dests no saca nada porque ya esta borrado ese nodo
				for k in Value_Sender_Dests'First..Value_Sender_Dests'Last loop
					if (Value_Sender_Dests(k).EP /= null)then						
						LLU.Send(Value_Sender_Dests(k).EP, Value_Sender_Buffering.P_Buffer);
						Value_Sender_Dests(k).Retries:= Value_Sender_Dests(k).Retries + 1;
						Debug.Put_Line (" RESEND TO " & Image_EP.Image(Value_Sender_Dests(k).EP) & " Retries " &
												Natural'Image(Value_Sender_Dests(k).Retries), Pantalla.Rojo);
						--Debug.Put_Line(Othrs.Destinations_T_To_String(Value_Sender_Dests), Pantalla.Verde); -- Para ver que me retransmite hasta el retrie 10
					end if;
				end loop;
				
				for k in Value_Sender_Dests'First..Value_Sender_Dests'Last loop
					if Value_Sender_Dests(k).Retries = 10 then
						Value_Sender_Dests(k).EP:= null;
					end if;
					
					if Value_Sender_Dests(k).EP /= null then
						Array_No_Nulo:= True;
					end if;
				end loop;
				
				if Array_No_Nulo = False then --El array es nulo
					Handler.Sender_Dests.Delete(Handler.My_SD_Map, Key_Sender_Dests, Success);
					
					Free(Value_Sender_Buffering.P_Buffer);
					-- Liberar Buffer
				else -- todavia hay vecinos
					Plazo_Retransmision:= 2 * Duration(Integer'Value(Ada.Command_Line.Argument(4))) / 1000;
					Nueva_Hora_Retransmision:= Ada.Calendar.Clock + Plazo_Retransmision;
					
					Handler.Sender_Buffering.Put(Handler.My_SB_Map, Nueva_Hora_Retransmision, Value_Sender_Buffering);
					Handler.Sender_Dests.Put(Handler.My_SD_Map, Key_Sender_Dests, Value_Sender_Dests);
					
					Timed_Handlers.Set_Timed_Handler (Nueva_Hora_Retransmision, Retransmisiones'Access);
				end if;
			end if;
		end if;
	end Retransmisiones;
	

	procedure Client_Handler (	From: in LLU.End_Point_Type;
										To: in LLU.End_Point_Type;
										P_Buffer: access LLU.Buffer_Type) is -- saco mensajes tipo server
		Mess: CM.Message_Type;
		Nick,Texto: ASU.Unbounded_String;
		Seq_N : Seq.Seq_N_T:= 0;
		Seq_Asociado: Seq.Seq_N_T:= 0;
		EP_R_Creat, EP_H_Creat, EP_H_Rsnd: LLU.End_Point_Type;
		Confirm_Sent, Success: Boolean:= False;
		
		Nick_Usuario: ASU.Unbounded_String;
		Array_EP: Handler.Neighbor.Keys_Array_Type;
		Longitud_Lista: Natural:= 0;
		Clock: Ada.Calendar.Time;
		Value_Sender_Dests: Othrs.Destinations_T;
		
		Plazo_Retransmision: Duration:= Duration(0);
		Hora_Retransmision: Ada.Calendar.Time; --Key_Sender_Buffering
		Se_Produce_Envio: Boolean:= False;
		Key_Sender_Dests: Othrs.Mess_Id_T;
		Se_Envia_Reject: Boolean:= False;
		Array_No_Nulo: Boolean:= False;
		Success_Neighbors: Boolean;
		Hora_Neighbor: Ada.Calendar.Time;
	begin
		
		Mess := CM.Message_Type'Input(P_Buffer);
		
		if (Mess = CM.Init) then
			Recibo_Init (P_Buffer, Nick, Seq_N, EP_H_Creat, EP_H_Rsnd, EP_R_Creat);
			
			Latest_Msgs.Get (My_Msgs, EP_H_Creat, Seq_Asociado,  Success);
			
			if (not Success) or (Success and (Seq_N = Seq_Asociado + 1)) then -- INIT NUEVO
			
			Debug.Put("RCV INIT NUEVO ", Pantalla.Azul_Claro);
			Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) , Pantalla.Verde);
			
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);		
				Debug.Put_Line(" ... Init", Pantalla.Verde);
				
				Latest_Msgs.Put (My_Msgs, EP_H_Creat, Seq_N, Success);
				Debug.Put_Line("Añadimos a latest_messages " & Image_EP.Image(EP_H_Creat) & Seq.Seq_N_T'Image(Seq_N), Pantalla.Verde);
				
				if (Nick = Handler.Nick_Usuario) then -- envio mensaje reject
					
					Mess:= CM.Reject;
					LLU.Reset(P_Buffer.all);
					
					CM.Message_Type'Output(P_Buffer, Mess);
					LLU.End_Point_Type'Output(P_Buffer, Handler.EP_H); --del nodo que envia el mensaje
					ASU.Unbounded_String'Output(P_Buffer, Handler.Nick_Usuario);
					
					LLU.Send(EP_R_Creat, P_Buffer);
					Se_Envia_Reject:= True;
					Debug.Put_Line("ENVIO REJECT " & Image_EP.Image(EP_H_Creat), Pantalla.Azul_Claro);
					
					--Borro Latest_Msgs
					Latest_Msgs.Delete (My_Msgs, EP_H_Creat, Success);
					Debug.Put_Line("Borramos de latest_msgs a " & Image_EP.Image(EP_H_Creat), Pantalla.Verde);
					
				else
					if (EP_H_Creat = EP_H_Rsnd) then --es mi vecino
						Clock:= Ada.Calendar.Clock;
						Neighbor.Put (My_Neighs, EP_H_Creat, Clock, Success);
						Debug.Put_Line("Añadimos a neighbors " & Image_EP.Image(EP_H_Creat), Pantalla.Verde);
					end if;
					
				 -- lo reenvio por inundacion
					Mess:= CM.Init;
					LLU.Reset(P_Buffer.all);
					
					CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
					
					CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
					LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
					Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
					LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
					LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_R_Creat);
					ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
					
					
					Debug.Put("FLOOD INIT ", Pantalla.Azul_Claro);
					Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
					Ada.Text_IO.New_Line;
					Pantalla.Poner_Color(Pantalla.Azul);		
					
					if (Se_Envia_Reject = False) and then (Se_Produce_Envio = True) then 
						Put_Sender_Buffering (CM.P_Buffer_Handler, Plazo_Retransmision, Hora_Retransmision, EP_H_Creat, Seq_N);
						Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, EP_H_Creat, Seq_N);
						
						Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
					end if;
				end if;
			end if;
			
			if (Success and (Seq_N <= Seq_Asociado)) then -- INIT PASADO
				Debug.Put("RCV INIT DEL PASADO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) , Pantalla.Verde);
				
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);		
				Debug.Put_Line(" ... Init", Pantalla.Verde);
			end if;
			
			if (Success and (Seq_N > Seq_Asociado + 1)) then -- INIT FUTUTO
				Debug.Put("RCV INIT DEL FUTURO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) , Pantalla.Verde);
			
				-- lo reenvio por inundacion
				Mess:= CM.Init;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_R_Creat);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				
				Debug.Put("FLOOD INIT ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				
			--No hago reenvios	
			end if;
		
		elsif (Mess = CM.Confirm) then
		
			Recibo_Confirm (P_Buffer, EP_H_Creat, Seq_N, EP_H_Rsnd, Nick);
			Ada.Text_IO.New_Line;
			
			Latest_Msgs.Get (My_Msgs, EP_H_Creat, Seq_Asociado,  Success);
			if (not success) or (Success and (Seq_N = Seq_Asociado + 1)) then --CONFIRM NUEVO
			
				Debug.Put("RCV CONFIRM NUEVO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) , Pantalla.Verde);
			
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);	
				Debug.Put_Line(" ... Confirm", Pantalla.Verde);	
			
				Pantalla.Poner_Color(Pantalla.Blanco);
				Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " ha entrado en el chat");
				Pantalla.Poner_Color(Pantalla.Azul);
				
				Latest_Msgs.Put (My_Msgs, EP_H_Creat, Seq_N, Success);
				Debug.Put_Line("Añadimos a latest_messages " & Image_EP.Image(EP_H_Creat) & Seq.Seq_N_T'Image(Seq_N), Pantalla.Verde);
				
				--Envio por inundacion
				Mess:= CM.Confirm;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				
				
				Debug.Put("FLOOD CONFIRM ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				if Se_Produce_Envio = True then 
					Put_Sender_Buffering (CM.P_Buffer_Handler, Plazo_Retransmision, Hora_Retransmision, EP_H_Creat, Seq_N);
					Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, EP_H_Creat, Seq_N);
					
					Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
				end if;
			end if;
			
			if (Success and (Seq_N <= Seq_Asociado)) then -- CONFIRM PASADO
				Debug.Put("RCV CONFIRM DEL PASADO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) , Pantalla.Verde);
			
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);		
				Debug.Put_Line(" ... Confirm", Pantalla.Verde);
			end if;
			
			if (Success and (Seq_N > Seq_Asociado + 1)) then -- CONFIRM FUTURO
				Debug.Put("RCV CONFIRM DEL FUTURO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) , Pantalla.Verde);
			
				--Envio por inundacion
				Mess:= CM.Confirm;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				
				
				Debug.Put("FLOOD CONFIRM ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				--No hago reenvios
			end if;
			
		elsif (Mess = CM.Logout) then
			
			Recibo_Logout (P_Buffer, EP_H_Creat, Seq_N, EP_H_Rsnd, Nick, Confirm_Sent);
			
			Latest_Msgs.Get (My_Msgs, EP_H_Creat, Seq_Asociado,  Success);
			if (Success and (Seq_N = Seq_Asociado + 1)) then  -- RECIBO LOGOUT NUEVO
				Debug.Put("RCV LOGOUT NUEVO ", Pantalla.Azul_Claro);
				if Confirm_sent = True then
					Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " TRUE", Pantalla.Verde);
				else
					Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " FALSE", Pantalla.Verde);
				end if;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);	
				Debug.Put_Line(" ... Logout", Pantalla.Verde);	
				
				if (Confirm_Sent = True) then
					Pantalla.Poner_Color(Pantalla.Blanco);
					Ada.Text_IO.Put_Line(ASU.To_String(Nick) & " ha abandonado el chat");
					Pantalla.Poner_Color(Pantalla.Azul);
				end if;
				
				
				Neighbor.Get (My_Neighs, EP_H_Creat, Hora_Neighbor, Success_Neighbors); --Si tiene vecinos
				if (Success_Neighbors) then
					Neighbor.Delete (My_Neighs, EP_H_Creat, Success_Neighbors);
					Debug.Put_Line("Borramos de neighbors a " & Image_EP.Image(EP_H_Creat), Pantalla.Verde);
				end if;
				
				Latest_Msgs.Delete (My_Msgs, EP_H_Creat, Success);
				Debug.Put_Line("Borramos de latest_msgs a " & Image_EP.Image(EP_H_Creat), Pantalla.Verde);
				
				--Envio por inundacion
				Mess:= CM.Logout;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				Boolean'Output(CM.P_Buffer_Handler, Confirm_Sent);
				
				
				Debug.Put("FLOOD LOGOUT ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				if Se_Produce_Envio = True then
					Put_Sender_Buffering (CM.P_Buffer_Handler, Plazo_Retransmision, Hora_Retransmision, EP_H_Creat, Seq_N);
					Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, EP_H_Creat, Seq_N);
					
					Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
				end if;
			else
				Debug.Put("RCV LOGOUT  ", Pantalla.Azul_Claro);
				
				Neighbor.Get (My_Neighs, EP_H_Creat, Hora_Neighbor, Success_Neighbors);
				if (Success_Neighbors) then
					Neighbor.Delete (My_Neighs, EP_H_Creat, Success_Neighbors);
					Debug.Put_Line("Borramos de neighbors a " & Image_EP.Image(EP_H_Creat), Pantalla.Verde);
				end if;
				
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);	
				Debug.Put_Line(" ... Logout", Pantalla.Verde);		
			end if;
			
			if (Success and (Seq_N <= Seq_Asociado)) then -- RECIBO LOGOUT PASADO
				Debug.Put("RCV LOGOUT DEL PASADO ", Pantalla.Azul_Claro);
				if Confirm_sent = True then
					Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " TRUE", Pantalla.Verde);
				else
					Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " FALSE", Pantalla.Verde);
				end if;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);
				Debug.Put_Line(" ... Logout", Pantalla.Verde);		
			end if;
			
			if (Success and (Seq_N > Seq_Asociado + 1)) then -- RECIBO LOGOUT FUTURO
				Debug.Put("RCV LOGOUT DEL FUTURO ", Pantalla.Azul_Claro);
				if Confirm_sent = True then
					Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " TRUE", Pantalla.Verde);
				else
					Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " FALSE", Pantalla.Verde);
				end if;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				--Envio por inundacion
				Mess:= CM.Logout;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				Boolean'Output(CM.P_Buffer_Handler, Confirm_Sent);
				
				
				Debug.Put("FLOOD LOGOUT ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				--No hago reenvios
			end if;
			
		elsif (Mess = CM.Writer) then	
		
			Recibo_Writer (P_Buffer, EP_H_Creat, Seq_N, EP_H_Rsnd, Nick, Texto);
			
			
			Latest_Msgs.Get (My_Msgs, EP_H_Creat, Seq_Asociado,  Success);
			
			if (not Success) or (Success and (Seq_N = Seq_Asociado + 1)) then -- RECIBO WRITER NUEVO
				
				Debug.Put("RCV WRITER NUEVO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " " & 
									ASU.To_String(Texto), Pantalla.Verde);
									
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);
				Debug.Put_Line(" ... Writer", Pantalla.Verde);		
								
				Pantalla.Poner_Color(Pantalla.Amarillo);
				Ada.Text_IO.Put(ASU.To_String(Nick) & ": ");
				Pantalla.Poner_Color(Pantalla.Azul);
				Ada.Text_IO.Put_Line(ASU.To_String(Texto));
				
				Latest_Msgs.Put (My_Msgs, EP_H_Creat, Seq_N, Success);
				Debug.Put_Line("Añadimos a latest_messages " & Image_EP.Image(EP_H_Creat) & Seq.Seq_N_T'Image(Seq_N), Pantalla.Verde);
				
				
				--Envio por inundacion
				Mess:= CM.Writer;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Texto);
				
				
				Debug.Put("FLOOD WRITER ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				if Se_Produce_Envio = True then 
						Put_Sender_Buffering (CM.P_Buffer_Handler, Plazo_Retransmision, Hora_Retransmision, EP_H_Creat, Seq_N);
						Put_Sender_Dests (Key_Sender_Dests, Value_Sender_Dests, EP_H_Creat, Seq_N);
						
						Timed_Handlers.Set_Timed_Handler (Hora_Retransmision, Handler.Retransmisiones'Access);
				end if;
			end if;
		
			if (Success and (Seq_N <= Seq_Asociado)) then -- RECIBO WRTIER PASADO
				Debug.Put("RCV WRITER DEL PASADO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " " & 
									ASU.To_String(Texto), Pantalla.Verde);
								
				--Envio ACK
				Envio_Ack (P_Buffer, Handler.EP_H, EP_H_Creat, Seq_N, Mess, EP_H_Rsnd);
				Debug.Put_Line(" ... Writer", Pantalla.Verde);		
			end if;
			
			if (Success and (Seq_N > Seq_Asociado + 1)) then -- RECIBO WRITER FUTURO
				Debug.Put("RCV WRITER DEL FUTURO ", Pantalla.Azul_Claro);
				Debug.Put_Line(Image_EP.Image(EP_H_Creat) & "... " & ASU.To_String(Nick) & " " & 
									ASU.To_String(Texto), Pantalla.Verde);
				
				--Envio por inundacion
				Mess:= CM.Writer;
				LLU.Reset(P_Buffer.all);
				
				CM.P_Buffer_Handler:= new LLU.Buffer_Type(1024);
				
				CM.Message_Type'Output(CM.P_Buffer_Handler, Mess);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, EP_H_Creat);
				Seq.Seq_N_T'Output(CM.P_Buffer_Handler, Seq_N);
				LLU.End_Point_Type'Output(CM.P_Buffer_Handler, Handler.EP_H);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Nick);
				ASU.Unbounded_String'Output(CM.P_Buffer_Handler, Texto);
				
				
				Debug.Put("FLOOD WRITER ", Pantalla.Azul_Claro);
				Envio_Por_Inundacion (CM.P_Buffer_Handler, Array_EP, Longitud_Lista, EP_H_Rsnd, Se_Produce_Envio, Value_Sender_Dests);
				Ada.Text_IO.New_Line;
				Pantalla.Poner_Color(Pantalla.Azul);
				
				--No hago reenvios
			end if;
		
		elsif (Mess = CM.Ack) then
			EP_H_Rsnd := LLU.End_Point_Type'Input (P_Buffer); --Nodo que envia el asentimiento
			EP_H_Creat := LLU.End_Point_Type'Input (P_Buffer);
			Seq_N := Seq.Seq_N_T'Input (P_Buffer);
			
			Debug.Put_Line("RCV ACK EP_Que_envia_Ack " & Image_EP.Image(EP_H_Rsnd) & " EP_H_Creat " &
								Image_EP.Image(EP_H_Creat) & " Seq: " & Seq.Seq_N_T'Image(Seq_N), Pantalla.Azul_Claro);
			Pantalla.Poner_Color(Pantalla.Azul);
			
			Key_Sender_Dests.EP:= EP_H_Creat;
			Key_Sender_Dests.Nseq:= Seq_N;
			
			Handler.Sender_Dests.Get(Handler.My_SD_Map, Key_Sender_Dests, Value_Sender_Dests, Success);
			
			for k in Value_Sender_Dests'First..Value_Sender_Dests'Last loop
				if (Value_Sender_Dests(k).EP = EP_H_Rsnd) then
					Value_Sender_Dests(k).EP := null;
				end if;
			end loop;
			
			for k in Value_Sender_Dests'First..Value_Sender_Dests'Last loop
				if Value_Sender_Dests(k).EP /= null then
					Array_No_Nulo:= True;
				end if;
			end loop;
			
			if Array_No_Nulo = False then --Array es nulo 
				Handler.Sender_Dests.Delete(Handler.My_SD_Map, Key_Sender_Dests, Success);
			else
				Handler.Sender_Dests.Put(Handler.My_SD_Map, Key_Sender_Dests, Value_Sender_Dests);
			end if;
		else
			Ada.Text_IO.Put_Line("NO RECIBO NADA");
		end if; --TIPOS DE MENSAJE QUE RECIBE
	end Client_Handler;

end Handler;

