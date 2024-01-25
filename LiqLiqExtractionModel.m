%{
- Título / Title: 
     Extracción Líquido-Líquido con Flujo Paralelo y en Contracorriente / Liquid-Liquid Extraction with Parallel Flow and Counterflow
- Fecha de Creación / Creation Date: 
     24 de enero de 2024 / January 24th, 2024
- Fecha de Última Edición / Last Edition Date:
     24 de enero de 2024 / January 24th, 2024
- Creado por / Created by:
     Priscilla Guerrero
%}


% Datos:
     % Fase mayoritaria en A:
     VBenA = [0.014615443 0.019440585 0.016834146 0.021379258 0.025579717 0.036608614 0.047755986 0.105690006 0.1666182]; % Eje X
     VCenA = [0.005560223 0.012189408 0.02869775 0.063960063 0.134463149 0.256758431 0.366939696 0.443186102 0.463278297]; % Eje Y
     % Fase mayoritaria en B:
     VBenB = [0.4903551 0.578866307 0.719140091 0.849709738 0.933492735 0.975335767 0.985244542 0.992643812]; % Eje X
     VCenB = [0.361180221 0.310909345 0.217914957 0.117168568 0.050357039 0.021907008 0.0087348 0.002159467]; % Eje Y
     % Distribución de C:
     VCenAeq = [0 0.014626213 0.048736093 0.116923541 0.182644566 0.209365946 0.24094478 0.347561041 0.422436912 0.443945416]; % Eje X
     %VCenBeq = [0 0.014626213 0.048736093 0.116923541 0.182644566 0.209365946 0.24094478 0.347561041 0.422436912 0.443945416];
     VCenBeq = [0.005105173 0.009574892 0.021839693 0.049673118 0.079698321 0.097437182 0.118501406 0.216988702 0.310930886 0.36168643]; % Eje Y

     Sistema = "Contracorriente";

switch(Sistema)
     case "Paralelo"

% 1. CONSIDERACIONES INICIALES:
     % Composiciones:
          FF = 200; xFA = 0.5; xFB = 0.05; xFC = 1 - xFA - xFB; FFA = FF * xFA; FFB = FF * xFB; FFC = FF * xFC; % Flujo Alimentación Muestra
          FS = 100; xSA = 0.01; xSB = 0.98; xSC = 1 - xSA - xSB; FSA = FS * xSA; FSB = FS * xSB; FSC = FS * xSC; % Flujo Alimentación Solvente
          FM = FF + FS; FMA = FFA + FSA; FMB = FFB + FSB; FMC = FFC + FSC; xMA = FMA / FM; xMB = FMB / FM; xMC = 1 - xMA - xMB; % Flujo Mezcla Alimentación
% 2. ESTABLECIMIENTO DE CICLO DE CONTEO DE ETAPAS
     %{
          Descripción del Procedimiento:
          1. Definir valores iniciales de F y S, para luego calcular M.
          2. Encontrar el equilibrio
               2a. Tomar valor máximo en X del equilibrio y ubicarlo en la recta de 45°.
               2b. Buscar intervalo de equilibrio apropiado sobre el eje X.
               2c. Determinar el respectivo valor sobre el equilibrio.
               2d. Buscar intervalo de distribución apropiado para el valor de la recta de 45° con respecto a la izquierda del domo.
               2e. Determinar el respectivo valor sobre la izquierda del domo
               2f. Buscar intervalo de distribución apropiado para el valor de la curva de equilibrio con respecto a la derecha del domo.
               2g. Determinar el respectivo valor sobre la derecha del domo
               2h. Determinar la ecuación de la recta entre los cortes de ambos lados.
               2i. Verificar que M se encuentre dentro de una tolerancia apropiada.
               2j. Continuar verificando haciendo decrementos moderados del valor y repetir desde el Paso 2b.
          3. Resolver el sistema de ecuaciones y determinar E y R:
          4. Calcular M para la siguiente etapa:
     %}
          

          Tol = 0.00005;
          Intentos = 100000; Incremento = 0.0001;
          Etapas = 10;
          j = 0;
%__________________________________________________________________________________________________
     while j < Etapas
          % Paso 2a: Valor sobre Recta de 45°
          Error = 1; k = 1;
          xa = min([max(VCenA), max(VCenB), max(VCenAeq), max(VCenBeq)] * 0.95); ya = xa;

          while Error > Tol
          % Paso 2b: Buscar intervalo en el equilibrio
               xa = xa - Incremento; ya = xa;
     
               for i = 1 : length(VCenAeq) - 1
                    if VCenAeq(length(VCenAeq) - i + 1) > xa && VCenAeq(length(VCenAeq) - i) < xa
          
               % Paso 2c: Ubicar valor de Recta de 45° sobre el equilibrio
                    % Ecuación de la Recta:
                    xb1 = VCenAeq(length(VCenAeq) - i); xb2 = VCenAeq(length(VCenAeq) - i + 1);
                    yb1 = VCenBeq(length(VCenBeq) - i); yb2 = VCenBeq(length(VCenBeq) - i + 1);
                    Mb = (yb2 - yb1) / (xb2 - xb1); Bb = yb1 - Mb * xb1;
                    % (Y - Y1) = m * (X - X1) -> -> Y  = m * X + (Y1 - m * X1)
                    Linab = @(x) Mb * x + Bb;
                    xb = xa; yb = Linab(xb);         
                    end
               end
     
               % Paso 2d: Buscar intervalo desde Recta de 45° a Curva de la Izquierda
               for i = 1 : length(VCenA) - 1
                    if VCenA(length(VCenA) - i + 1) > ya && VCenA(length(VCenA) - i) < ya
                    
               % Paso 2e: Ubicar valor de Recta de 45° sobre la izquierda del domo:
                    % Ecuación de la Recta:
                    xc1 = VBenA(length(VBenA) - i); xc2 = VBenA(length(VBenA) - i + 1);
                    yc1 = VCenA(length(VCenA) - i); yc2 = VCenA(length(VCenA) - i + 1);
                    Mc = (yc2 - yc1) / (xc2 - xc1); Bc = yc1 - Mc * xc1;
                    % (Y - Y1) = m * (X - X1) -> -> Y  = m * X + (Y1 - m * X1) -> -> X = [Y - (Y1 - m * X1)] / m
                    Linac = @(y) (y - Bc) / Mc;
                    yc = ya; xc = Linac(yc);
                    end
               end
     
               % Paso 2f: Buscar intervalo desde Curva de Equilibrio a Curva de la Derecha
               for i = 1 : length(VCenB) - 1
                    if (VCenB(length(VCenB) - i + 1) < yb && VCenB(length(VCenB) - i) > yb) % Orden revertido requerido
          
               % Paso 2g: Ubicar valor de Curva de Equilibrio sobre la derecha del domo:
                    % Ecuación de la Recta:
                    xd1 = VBenB(length(VBenB) - i); xd2 = VBenB(length(VBenB) - i + 1);
                    yd1 = VCenB(length(VCenB) - i); yd2 = VCenB(length(VCenB) - i + 1);
                    Md = (yd2 - yd1) / (xd2 - xd1); Bd = yd1 - Md * xd1;
                    % (Y - Y1) = m * (X - X1) -> -> Y  = m * X + (Y1 - m * X1) -> -> X = [Y - (Y1 - m * X1)] / m
                    Linbd = @(y) (y - Bd) / Md;
                    yd = yb; xd = Linbd(yd);
                    end
               end
          
               % Paso 2h: Ecuación de la Recta entre Izquierda y Derecha
                    MID = (yc - yd) / (xc - xd); BID = yd - MID * xd;
                    LinID = @(x) MID * x + BID;
     
               % Paso 2i: Verificar Exactitud de la curva con el valor de x
                    yMC = LinID(xMB);
                    Error = abs(yMC - xMC);
                    
                    if k > Intentos
                         Error = 0;
                    end
                    
                    k = k + 1;
     
               end
               
               k = 1;
               
               % Gráfica:
                    subplot(1, 2, 2);
                    plot([xa, xb], [ya, yb], "Color", [0.4 0.8 0.2], "linewidth", 1.5); hold on; % Línea Vertical entre Recta de 45° (xa, ya) y Curva de Equilibrio (xb, yb)
                    plot([0, xa], [ya, yc], "Color", [1.0 0.2 0.6], "linewidth", 1.5); hold on; % Línea Horizontal entre Recta de 45° (xa, ya) y Domo Izquierdo (xc, yc)
                    plot([0, xb], [yb, yd], "Color", [1.0 0.8 0.2], "linewidth", 1.5); hold on; % Línea Horizontal entre Curva de Equilibrio (xb, yb) y Domo Derecho (xd, yd)
                    subplot(1, 2, 1);
                    plot([xc, 1], [yc, ya], "Color", [1.0 0.2 0.6], "linewidth", 1.5); hold on; % Línea Horizontal entre Recta de 45° (xa, ya) y Domo Izquierdo (xc, yc)
                    plot([xd, 1], [yd, yb], "Color", [1.0 0.8 0.2], "linewidth", 1.5); hold on; % Línea Horizontal entre Curva de Equilibrio (xb, yb) y Domo Derecho (xd, yd)
                    plot([xc, xd], [yc, yd], "Color", [0.4 0.8 0.2], "linewidth", 1.5); hold on; % Línea en el Interior del Domo entre los dos equilibrios
                    plot([xc, xSB], [yc, xSC], "Color", [0.0 0.4 0.0], "linewidth", 1.5); hold on; % Línea desde Domo Izquierdo (xc, yc) y punto de solvente

     % PASO 3:
          % (xc, yc): (B en Refinado, C en Refinado) / (xd, yd): (B en Extracto, C en Extracto)
          xRB = xc; xRC = yc; xRA = 1 - xRB - xRC; xEB = xd; xEC = yd; xEA = 1 - xEB - xEC;

          % Sistema de ecuaciones:
               % FMA = xRA * FR + xEA * FE / FMB = xRB * FR + xEB * FE / FMC = xRC * FR + xEC * FE
               % FR = -(xEA * FE) / xRA + FMA / xRA <= => Y = P * X + Q 
               % Y = m1 * X + b1; Y = m2 * X + b2 -> -> Y = Y -> -> m1 * X + b1 = m2 * X + b2 -> -> X = - (b1 - b2) / (m1 - m2)
               
          PA = -xEA / xRA; QA = FMA / xRA; EcA = @(X) PA * X + QA; 
          PB = -xEB / xRB; QB = FMB / xRB; EcB = @(X) PB * X + QB; 
          PC = -xEC / xRC; QC = FMC / xRC; EcC = @(X) PC * X + QC; 

          SolAB = -(QA - QB) / (PA - PB); SolAC = -(QA - QC) / (PA - PC); SolBC = -(QB - QC) / (PB - PC); PromSol = (SolAB + SolAC + SolBC) / 3;

          FE = PromSol; FEA = FE * xEA; FEB = FE * xEB; FEC = FE * xEC;
          FR = FM - FE; FRA = FR * xRA; FRB = FR * xRB; FRC = FR * xRC;
     % Recoger Información: Etapa, FM, FMA, XMA, FMB, XMB, FMC, XMC, FE, FEA, XEA, FEB, XEB, FEC, XEC, FR, FRA, XRA, FRB, XRB, FRC, XRC
          FilaInfo(j + 1, :) = [j + 1, FM, FMA, xMA, FMB, xMB, FMC, xMC, FE, FEA, xEA, FEB, xEB, FEC, xEC, FR, FRA, xRA, FRB, xRB, FRC, xRC];

     % Paso 4: Repetir
          FS = 100; xSA = 0.01; xSB = 0.98; xSC = 1 - xSA - xSB; FSA = FS * xSA; FSB = FS * xSB; FSC = FS * xSC; % Flujo Alimentación Solvente
          FMA = FSA + FRA; FMB = FSB + FRB; FMC = FSC + FRC; FM = FMA + FMB + FMC; xMA = FMA / FM; xMB = FMB / FM; xMC = FMC / FM;

          j = j + 1; xa = 0; ya = 0; xb = 0; yb = 0; xc = 0; yc = 0; xd = 0; yd = 0; Error = 1;
     
     end


% 3. ENTREGA DE INFORMACIÓN:
     % Primera Gráfica: Concentración de Especie B (x) vs Concentración de Especie C (y)
          Amp = 1.05;
          % Detalles Globales:
          subplot(1, 2, 1); hold on; axis([0 1 0 max([max(VCenA), max(VCenB), max(VCenBeq)]) * Amp]); hold on;
          xlabel("Fracción de Especie B"); ylabel("Fracción de Especie C"); hold on;
          title("Distribucción de Especies A, B y C en la Mezcla Bifásica Líquido-Líquido"); grid on; hold on;
          % Gráfica de Equilibrio:        
          plot(VBenA, VCenA, "Color", [0.4 0.0 0.4], "linewidth", 3); hold on; % Curva de Distribución en Mayoritaria de A (Púrpura)
          plot(VBenB, VCenB, "Color", [0.6 0.4 0.0], "linewidth", 2.5); hold on; % Curva de Distribución en Mayoritaria de B (Marrón)
          % Detalles Adicionales
          plot(FilaInfo(:, 6), FilaInfo(:, 8), "o", "Color", [0.0 0.0 0.0], "linewidth", 3); hold on; % Puntos M
          plot([xFB, xSB], [xFC, xSC], "Color", [0.0 0.4 0.0], "linewidth", 1.5); hold on; % Recta Alimentación - Solvente

     % Segunda Gráfica: Concentración de Especie C en A (x) vs Concentración de Especie C en B (y)
          % Detalles Globales:
          subplot(1, 2, 2); hold on; axis([0 max(VCenAeq) * Amp 0 max([max(VCenA), max(VCenB), max(VCenBeq)]) * Amp]); hold on;
          xlabel("Fracción de Especie C en A"); ylabel("Fracción de Especie C en B"); hold on;
          title("Distribucción de Especie C en la Mezcla Bifásica Líquido-Líquido"); grid on; hold on;
          % Gráfica de Equilibrio:        
          plot(VCenAeq, VCenBeq, "Color", [0.6 0.4 0.0], "linewidth", 3); hold on; % Curva de Equilibrio (Marrón)
          plot(VCenAeq, VCenAeq, "--", "Color", [0.4 0 0.4], "linewidth", 2.5); hold on; % Línea de 45° (Púrpura)
          
     % Tabla:
     Tabla = ["Etapa", "FM", "FMA", "XMA", "FMB", "XMB", "FMC", "XMC", "FE", "FEA", "XEA", "FEB", "XEB", "FEC", "XEC", "FR", "FRA", "XRA", ...
               "FRB", "XRB", "FRC", "XRC";
               FilaInfo];
     disp(Tabla)









     case "Contracorriente"

% 1. CONSIDERACIONES GENERALES
     % Composiciones:
          FF = 200; xFA = 0.6; xFB = 0.05; xFC = 1 - xFA - xFB; FFA = FF * xFA; FFB = FF * xFB; FFC = FF * xFC; % Flujo Alimentación Muestra
          FS = 400; xSA = 0.01; xSB = 0.98; xSC = 1 - xSA - xSB; FSA = FS * xSA; FSB = FS * xSB; FSC = FS * xSC; % Flujo Alimentación Solvente
          FM = FF + FS; FMA = FFA + FSA; FMB = FFB + FSB; FMC = FFC + FSC; xMA = FMA / FM; xMB = FMB / FM; xMC = 1 - xMA - xMB;  % Flujo Mezcla Global
          xRnpA = 0; xRnpB = 0; xRnpC = 0.05;

% 2. ESTABLECIMIENTO DE CICLO DE CONTEO DE ETAPAS
%{
     1. Caracterizar el estado Rnp
     2. Establecer la ecuación de recta global (RNP - M - E1)
     3. Buscar el intervalo en el domo de la derecha apropiado para determinar el valor de E1.
     4. Establecer ecuaciones de recta F - E1 - DeltaR y RNP - S - DeltaR
     5. Determinar el valor de Delta R
     6. Transporte desde E1 hasta curva de equilibrio
     7. Tomar valor en recta de 45°
     8. Transporte desde 45° hasta domo izquierdo
     9. Recta Pivote desde domo izquierdo hasta DeltaR
     10. Determinar E2 y continuar

%}

% PASO 1:
     for i = 1 : length(VCenA) - 1
          if VCenA(length(VCenA) - i + 1) > xRnpC && VCenA(length(VCenA) - i) < xRnpC
               xa1 = VBenA(length(VBenA) - i + 1); xa2 = VBenA(length(VBenA) - i); 
               ya1 = VCenA(length(VCenA) - i + 1); ya2 = VCenA(length(VCenA) - i); 
               Ma = (ya2 - ya1) / (xa2 - xa1); Ba = ya1 - Ma * xa1; LinNP = @(y) (y - Ba) / Ma;
               % (Y - Y1) = m * (X - X1) -> -> Y  = m * X + (Y1 - m * X1) -> -> X = [Y - (Y1 - m * X1)] / m 
               xRnpB = LinNP(xRnpC); xRnpA = 1 - xRnpB - xRnpC;
               subplot(1, 2, 1)
               plot([xRnpB xRnpB], [xRnpC xRnpC], "o"); hold on;
          end
     end
     
% PASO 2:
     x1Lin1 = xRnpB; y1Lin1 = xRnpC; x2Lin1 = xMB; y2Lin1 = xMC;
     MLin1 = (y2Lin1 - y1Lin1) / (x2Lin1 - x1Lin1); BLin1 = y2Lin1 - MLin1 * x2Lin1; Lin1 = @(x) MLin1 * x + BLin1;

% PASO 3:
     for i = 1 : length(VCenB) - 1
          x1CorE1 = VBenB(length(VBenB) - i + 1); x2CorE1 = VBenB(length(VBenB) - i); 
          y1CorE1 = VCenB(length(VCenB) - i + 1); y2CorE1 = VCenB(length(VCenB) - i); 
          MCorE1 = (y2CorE1 - y1CorE1) / (x2CorE1 - x1CorE1); BCorE1 = y2CorE1 - MCorE1 * x2CorE1; LinCorE1 = @(x) MCorE1 * x + BCorE1; %@(y) (y - Ba) / Ma;
          
          x3CorE1 = -(BCorE1 - BLin1) / (MCorE1 - MLin1);

          if VBenB(length(VBenB) - i + 1) > x3CorE1 && x3CorE1 > VBenB(length(VBenB) - i)
               x3CorE1T = x3CorE1;
               y3CorE1T = LinCorE1(x3CorE1T);
          end
     end

         plot([xRnpB x3CorE1T], [xRnpC y3CorE1T]); hold on; % Recta     % plot([0 1], [xMC xMC]); hold on; plot([xMB xMB], [0 1]); hold on;

% PASO 4:
     % Recta F-E1-DeltaR
     x1FE1DR = xFB; y1FE1DR = xFC; x2FE1DR = x3CorE1T; y2FE1DR = y3CorE1T;
     MFE1DR = (y2FE1DR - y1FE1DR) / (x2FE1DR - x1FE1DR); BFE1DR = y1FE1DR - MFE1DR * x1FE1DR; LinFE1R = @(x) MFE1DR * x + BFE1DR;
     % (Y - Y1) = m * (X - X1) -> -> Y  = m * X + (Y1 - m * X1) -> -> X = [Y - (Y1 - m * X1)] / m 

     % Recta Rnp-S-DeltaR
     x1RnpSDR = xRnpB; y1RnpSDR = xRnpC; x2RnpSDR = xSB; y2RnpSDR = xSC;
     MRnpSDR = (y2RnpSDR - y1RnpSDR) / (x2RnpSDR - x1RnpSDR); BRnpSDR = y1RnpSDR - MRnpSDR * x1RnpSDR; LinRnpSDR = @(x) MRnpSDR * x + BRnpSDR;

% PASO 5:
     % Delta R
     xDR = -(BRnpSDR - BFE1DR) / (MRnpSDR - MFE1DR);
     yDR = LinRnpSDR(xDR);

     plot([xFB x3CorE1T xDR], [xFC y3CorE1T yDR]); hold on;
     plot([xRnpB xSB xDR], [xRnpC xSC yDR]); hold on;

% PASO 6:
          xa = x3CorE1T; ya = y3CorE1T;
          yd = 1;
k = 1;
     while yd > xRnpC && k < 50
          for i = 1 : length(VCenBeq) - 1
               if VCenBeq(length(VCenBeq) - i + 1) > ya && ya > VCenBeq(length(VCenBeq) - i)
                    xb1 = VCenAeq(length(VCenAeq) - i); yb1 = VCenBeq(length(VCenBeq) - i);
                    xb2 = VCenAeq(length(VCenAeq) - i + 1); yb2 = VCenBeq(length(VCenBeq) - i + 1);
                    Mb = (yb2 - yb1) / (xb2 - xb1); Bb = yb1 - Mb * xb1; Linb = @(y) (y - Bb) / Mb;

                    yb = ya; xb = Linb(yb);
                    subplot(1, 2, 1)
                    plot([xa, 1], [ya ya]); hold on;
                    subplot(1, 2, 2)
                    plot([0, xb], [ya yb]); hold on;
               end
          end

% PASO 7:
     xc = xb; yc = xc;
     plot([xc, xc], [yb yc]); hold on;

% PASO 8:
     for i = 1 : length(VCenA) - 1
          if VCenA(length(VCenA) - i + 1) > yc && yc > VCenA(length(VCenA) - i)
               xd1 = VBenA(length(VBenA) - i + 1); yd1 = VCenA(length(VCenA) - i + 1);
               xd2 = VBenA(length(VBenA) - i); yd2 = VCenA(length(VCenA) - i);
               Md = (yd2 - yd1) / (xd2 - xd1); Bd = yd1 - Md * xd1; Lind = @(y) (y - Bd) / Md;

               yd = yc; xd = Lind(yd);
               subplot(1, 2, 2)
               plot([0, xc], [yc yd]); hold on;
               subplot(1, 2, 1)
               plot([xd, 1], [yd yd]); hold on;
                    
          end
     end

% PASO 9:
     subplot(1, 2, 1)
     plot([xd, xDR], [yd yDR]); hold on;
     MIzDr = (yd - yDR) / (xd - xDR); BIzDr = yd - MIzDr * xd; LinIzDr = @(x) MIzDr * x + BIzDr;

% PASO 10:
     for i = 1 : length(VCenB) - 1
          xe1 = VBenB(length(VBenB) - i + 1); ye1 = VCenB(length(VCenB) - i + 1);
          xe2 = VBenB(length(VBenB) - i); ye2 = VCenB(length(VCenB) - i);
          Me = (ye2 - ye1) / (xe2 - xe1); Be = ye2 - Me * xe2; Lin_e = @(x) Me * x + Be; % Para evitar "Line" y generar errores ksksks

          xeCor = -(Be - BIzDr) / (Me - MIzDr);     

          if VBenB(length(VCenB) - i + 1) > xeCor && xeCor > VBenB(length(VCenB) - i)
               xeCorT = xeCor;
               yeCorT = Lin_e(xeCorT);
          end
     end

          xa = xeCorT; ya = yeCorT;

          k = k + 1;
     end
     %subplot(1, 2, 1) %plot([xd xeCorT], [yd yeCorT])

     

% 3. ENTREGA DE INFORMACIÓN
     % Primera Gráfica: Concentración de Especie B (x) vs Concentración de Especie C (y)
          Amp = 1.05;
          % Detalles Globales:
          subplot(1, 2, 1); hold on; axis([0 1 0 max([max(VCenA), max(VCenB), max(VCenBeq)]) * Amp]); hold on;
          xlabel("Fracción de Especie B"); ylabel("Fracción de Especie C"); hold on;
          title("Distribucción de Especies A, B y C en la Mezcla Bifásica Líquido-Líquido"); grid on; hold on;
          % Gráfica de Equilibrio:        
          plot(VBenA, VCenA, "Color", [0.4 0.0 0.4], "linewidth", 3); hold on; % Curva de Distribución en Mayoritaria de A (Púrpura)
          plot(VBenB, VCenB, "Color", [0.6 0.4 0.0], "linewidth", 2.5); hold on; % Curva de Distribución en Mayoritaria de B (Marrón)

     % Segunda Gráfica: Concentración de Especie C en A (x) vs Concentración de Especie C en B (y)
          % Detalles Globales:
          subplot(1, 2, 2); hold on; axis([0 max(VCenAeq) * Amp 0 max([max(VCenA), max(VCenB), max(VCenBeq)]) * Amp]); hold on;
          xlabel("Fracción de Especie C en A"); ylabel("Fracción de Especie C en B"); hold on;
          title("Distribucción de Especie C en la Mezcla Bifásica Líquido-Líquido"); grid on; hold on;
          % Gráfica de Equilibrio:        
          plot(VCenAeq, VCenBeq, "Color", [0.6 0.4 0.0], "linewidth", 3); hold on; % Curva de Equilibrio (Marrón)
          plot(VCenAeq, VCenAeq, "--", "Color", [0.4 0 0.4], "linewidth", 2.5); hold on; % Línea de 45° (Púrpura)







end
