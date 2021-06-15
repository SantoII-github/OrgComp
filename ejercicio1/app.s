.equ SCREEN_WIDTH, 		640
.equ SCREEN_HEIGH, 		480
.equ BITS_PER_PIXEL,  	32
.equ ONE_LINE, 0xA00
.equ THREE_LINES, 0x1E00
.equ SIX_LINES, 0x3C00
.equ SECOND_CENTER, 0x3214
.equ BIG_STAR_1, 0x45f4
.equ BIG_STAR_2, 0x1de4
.equ BIG_STAR_3, 0x1408
.equ WHITE, 0xFFFFFF


.globl main
main:
	// X0 contiene la direccion base del framebuffer
 	mov x20, x0	// Save framebuffer base address to x20	
	//---------------- CODE HERE ------------------------------------
	
	b graph            // Voy a la parte del código donde llamo a mis procedimientos.
	
paintarea:
	// Desc: Pinta un área del tamaño x10*x11 con su esquina superior izquierda ubicada en las coordenadas x9, todo con el color guardado en x12.
	// Parámetros:
	// x9 = Dirección de coordenadas en formato Dirección de inicio + 4*(x+(y*640)). La esquina superior izquierda del área.
	// x10 = Alto del área en pixeles.
	// x11 = Ancho del área en pixeles.
	// x12 = Color del cual pintar el área.
	// Algoritmo: Pinto el primer pixel. Avanzo uno. Repito hasta completar la primera fila. Bajo una columna. Repito con la nueva fila.
	// Dentro del procedimiento: x13 = Coordenadas Pixel Actual, x14 = Altura, x15 = Ancho, x16 = Ancho * 4, x17 = x20 + 0x12CA00, Última dirección del framebuffer

	mov x13, x9		 // Uso x13 para las coordenadas para no modificar x9.
	lsl x16, x11, 2         // Guardo en x16 el ancho multiplicado por 4 para usar como dirección más adelante.
	mov x14, x10            // Guardo en x14 la altura para no modificar x10.
	movz x17, 0x12, lsl 16  // Guardo en x17 la última dirección del framebuffer.
	movk x17, 0xca00, lsl 0 // Ver arriba
	add x17, x20, x17	 // Ver arriba
paintloop0:	
	mov x15, x11            // Guardo en x15 el ancho para usarlo cuando cambio de línea.
paintloop1:
	subs xzr, x13, x20	 // Si x13 es menor a la dirección base del framebuffer, es decir no está en pantalla, no lo pinto.
	b.lt skippaint		 // Ver arriba.
	subs xzr, x13, x17	 // Si x13 es mayor a la dirección final del framebuffer, es decir no está en pantalla, no lo pinto.
	b.gt skippaint		 // Ver arriba.
	stur w12, [x13]	 // Pintar el pixel que corresponde del color guardado en x12.
skippaint:
	add x13, x13, 4	 // Próximo pixel.
	sub x15, x15, 1         // Decrementa el contador de ancho.
	cbnz x15, paintloop1    // Si el ancho no llegó a 0, pinta el próximo pixel.
	add x13, x13, ONE_LINE  // Si el ancho llegó a 0, avanzo a la próxima línea.
	sub x13, x13, x16       // Resto el ancho*4 a la dirección para estar en el primer pixel de la línea.
	sub x14, x14, 1         // Decremento el contador de altura.
	cbnz x14, paintloop0    // Si el contador de altura != 0, pinto la línea. Si era la última termino.
	br x30                  // Vuelvo a donde llamé el procedimiento


starmedium:
	// Desc: Pinta una estrella de tamaño mediano centrada en las coordenadas x0, con los colores x1 y x2
	// Parámetros: 
	// x0 = Dirección de coordenadas en formato Dirección de inicio + 4*(x+(y*640)). El centro exacto de la estrella.
	// x1 = Color primario, el centro de la estrella.
	// x2 = Color secundario, el resto de la estrella.
	sub sp, sp, 8		 // Hago espacio en el stack para guardar un registro
	stur x30, [sp, 0]	 // Guardo x30 en el stack
	
	mov x12, x2             // x12 = x2. las puntas de la estrella son del color secundario.
	
	// Pinto la parte vertical de la estrella
	mov x13, SIX_LINES	 // Guardo temporalmente en x13 un inmediato que se saldría de rango.
	sub x9, x0, 0xA04	 // x9 = x0 - 0xA04. Pixel superior izquierdo del centro de la estrella.
	sub x9, x9, x13     	 // x9 = x9 - 0x3C00. Pixel superior izquierdo de la parte superior de la estrella. 0x3C00 son 6 líneas.

	movz x10, 0xF, lsl 0    // x10 = 15. Área de 15 de altura. 
	movz x11, 0x3, lsl 0    // x11 = 3. Área de 3 de ancho.
	bl paintarea		 
	
	// Pinto la parte horizontal de la estrella
	sub x9, x0, 0xA1C	 // x9 = x0 - 0xA1C. Pixel superior izquierdo de la parte izquierda de la estrella.
	movz x10, 0x3, lsl 0    // x10 = 3. Área de 3 de altura.
	movz x11, 0xF, lsl 0    // x11 = 15. Área de 15 de ancho.
	bl paintarea
	
	// Pinto el centro de la estrella
	add x9, x9, 0x18	 // x9 = x9 + 0x18. Pixel superior izquierdo del centro de la estrella.
	movz x10, 0x3, lsl 0    // x10 = 3. Área de 3 de altura.
	movz x11, 0x3, lsl 0    // x11 = 3. Área de 3 de ancho.
	mov x12, x1             // x12 = x1. El centro de la estrella es del color primario.
	bl paintarea
	
	ldur x30, [sp, 0]       // Recupero x30 del stack
	add sp, sp, 8           // Restauro el stack
	
	br x30			 // Vuelvo a donde llamé el procedimiento


starsmall:
	// Desc: Pinta una estrella de tamaño pequeño con su esquina superior izquierda en las coordenadas x0 y el color x2
	// Parámetros: 
	// x0 = Dirección de coordenadas en formato Dirección de inicio + 4*(x+(y*640)). La esquina superior izquierda de la estrella.
	// x1 = Color de la estrella.
	sub sp, sp, 8		 // Hago espacio en el stack para guardar un registro
	stur x30, [sp, 0]	 // Guardo x30 en el stack
	
	mov x9, x0		 // x9 = x0. Esquina superior izquierda de la estrella.
	movz x10, 0x4, lsl 0    // x10 = 4. Área de 4 de alto
	movz x11, 0x4, lsl 0    // x11 = 4. Área de 4 de ancho
	mov x12, x1             // x12 = x1. Color del cual pintar.
	bl paintarea
	
	ldur x30, [sp, 0]       // Recupero x30 del stack
	add sp, sp, 8           // Restauro el stack
	
	br x30			 // Vuelvo a donde llamé el procedimiento


starbig:
	// Desc: Pinta una estrella de tamaño grande centrada en las coordenadas x0, con los colores x1, x2 y x3
	// Parámetros: 
	// x0 = Dirección de coordenadas en formato Dirección de inicio + 4*(x+(y*640)). El centro exacto de la estrella.
	// x1 = Color primario, el centro de la estrella.
	// x2 = Color secundario, las puntas de la estrella
	// x3 = Color terciario, el "segundo centro" de la estrella
	sub sp, sp, 8		 // Hago espacio en el stack para guardar un registro
	stur x30, [sp, 0]	 // Guardo x30 en el stack
	
	// Pinto el "segundo centro" de la estrella
	mov x13, SECOND_CENTER	// Guardo temporalmente en x13 un inmediato que se saldría de rango.
	sub x9, x0, x13	// x9 = x0 - 0x3214. Pixel superior izquierdo del "segundo centro" de la estrella.
	movz x10, 0xB, lsl 0	// x10 = 11. area de 15 de altura.
	movz x11, 0xB, lsl 0	// x11 = 11. area de 15 de ancho.
	mov x12, x3		// x12 = x3. el "segundo centro" de la estrella es del color terciario.
	bl paintarea
	
	mov x12, x2             // x12 = x2. las puntas de la estrella son del color secundario.
	
	// Pinto la parte vertical de la estrella
	mov x13, BIG_STAR_1	  
	sub x9, x9, x13	 // x9 = x0 - 0x59f4. Pixel superior izquierdo de la estrella. 
	movz x10, 0x19, lsl 0   // x10 = 25. Área de 25 de altura.
	movz x11, 0x5, lsl 0    // x11 = 3. Área de 5 de ancho.
	bl paintarea		 
	
	// Pinto la parte horizontal de la estrella
	mov x13, BIG_STAR_1	 
	add x9, x9, x13	 // x9 = x9 + 0x59f4. Pixel superior izquierdo del "segundo centro" de la estrella.
	mov x13, BIG_STAR_2
	add x9, x9, x13	 // x9 = x9 + 0x13e4. Pixel superior izquierdo del lado izquierdo de la estrella.
	movz x10, 0x5, lsl 0    // x10 = 5. Área de 5 de altura.
	movz x11, 0x19, lsl 0   // x11 = 25. Área de 25 de ancho.
	bl paintarea
	
	// Pinto el centro de la estrella
	mov x13, BIG_STAR_3
	sub x9, x0, x13	 // x9 = x0 - 0x1408. Pixel superior izquierdo del centro de la estrella.
	movz x10, 0x5, lsl 0    // x10 = 3. Área de 5 de altura.
	movz x11, 0x5, lsl 0    // x11 = 3. Área de 5 de ancho.
	mov x12, x1             // x12 = x1. El centro de la estrella es del color primario.
	bl paintarea
	
	ldur x30, [sp, 0]       // Recupero x30 del stack
	add sp, sp, 8           // Restauro el stack
	
	br x30			 // Vuelvo a donde llamé el procedimiento


graph:
	// Grafica la imagen principal.

	// Pinto todo el fondo de negro.
	mov x9, x20
	movz x10, SCREEN_HEIGH, lsl 0
	movz x11, SCREEN_WIDTH, lsl 0
	movz x12, 0x00, lsl 16
	movz x12, 0x0000, lsl 0
	bl paintarea
	
	// Dibujo las estrellas pequeñas color malva
	movz x0, 0x2, lsl 16    // Cargando coord(260, 70) en x0.
	movk x0, 0xC010, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	movz x1, 0xAB, lsl 16	 // El color de la estrella va a ser malva.
	movk x1, 0xA3C1, lsl 0  // Ver arriba.
	bl starsmall
	
	movz x0, 0x4, lsl 16    // Cargando coord(575, 125) en x0.
	movk x0, 0xEAFC, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x7, lsl 16    // Cargando coord(300, 200) en x0.
	movk x0, 0xD4B0, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x9, lsl 16    // Cargando coord(30, 240) en x0.
	movk x0, 0x6078, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0xE, lsl 16    // Cargando coord(480, 360) en x0.
	movk x0, 0x1780, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	// Dibujo las estrellas medianas
	movz x0, 0x1, lsl 16    // Cargando coord(50, 50) en x0.
	movk x0, 0xF4C8, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	mov x1, WHITE		 // El color primario de la estrella va a ser blanco.
	movz x2, 0x67, lsl 16   // El color secundario de la estrella va a ser púrpura claro.
	movk x2, 0x5796, lsl 0  // Ver arriba.
	bl starmedium
	
	movz x0, 0x3, lsl 16    // Cargando coord(150, 100) en x0.
	movk x0, 0xEA58, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starmedium
	
	movz x0, 0x4, lsl 16    // Cargando coord(450, 115) en x0.
	movk x0, 0x8508, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starmedium
	
	movz x0, 0xD, lsl 16    // Cargando coord(350, 200) en x0.
	movk x0, 0x4B48, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starmedium
	
	movz x0, 0x10, lsl 16    // Cargando coord(390, 410) en x0.
	movk x0, 0x0A18, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starmedium
	
	movz x0, 0xF, lsl 16    // Cargando coord(390, 410) en x0.
	movk x0, 0xA898, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starmedium
	
	// Dibujo las estrellas pequeñas color blanco
	movz x0, 0x2, lsl 16    // Cargando coord(110, 60) en x0.
	movk x0, 0x59B8, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x1, lsl 16    // Cargando coord(520, 50) en x0.
	movk x0, 0xFC20, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x4, lsl 16    // Cargando coord(45, 115) en x0.
	movk x0, 0x7EB4, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x4, lsl 16    // Cargando coord(290, 110) en x0.
	movk x0, 0x5088, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x07, lsl 16    // Cargando coord(200, 200) en x0.
	movk x0, 0xD320, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x9, lsl 16    // Cargando coord(150, 250) en x0.
	movk x0, 0xC658, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0xA, lsl 16    //  Cargando coord(400, 270) en x0.
	movk x0, 0x9240, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0xD, lsl 16    // Cargando coord(580, 340) en x0.
	movk x0, 0x5110, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x11, lsl 16    // Cargando coord(50, 450) en x0.
	movk x0, 0x94C8, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	movz x0, 0x10, lsl 16    // Cargando coord(260, 410) en x0.
	movk x0, 0x0810, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.	
	bl starsmall
	
	// Dibujo las estrellas grandes
	movz x0, 0x2, lsl 16    // Cargando coord(340, 60) en x0.
	movk x0, 0x5D50, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	movz x3, 0xAB, lsl 16	 // El color terciario de la estrella va a ser malva.
	movk x3, 0xA3C1, lsl 0  // Ver arriba.
	bl starbig
	
	movz x0, 0xB, lsl 16    // Cargando coord(300, 300) en x0.
	movk x0, 0xBCB0, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starbig
	
	movz x0, 0xA, lsl 16    // Cargando coord(80, 270) en x0.
	movk x0, 0x8D40, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starbig
	
	movz x0, 0xF, lsl 16    // Cargando coord(150, 400) en x0.
	movk x0, 0xA258, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starbig
		
	movz x0, 0x7, lsl 16    // Cargando coord(350, 200) en x0.
	movk x0, 0xD578, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starbig
	
	movz x0, 0x9, lsl 16    // Cargando coord(500, 240) en x0.
	movk x0, 0x67D0, lsl 0  // Ver arriba.
	add x0, x0, x20	 // Ver arriba.
	bl starbig

	
	//---------------------------------------------------------------
	// Infinite Loop 

InfLoop: 
	b InfLoop
