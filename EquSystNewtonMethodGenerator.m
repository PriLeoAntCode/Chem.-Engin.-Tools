% Elaborador de Código de Método de Newton:

% Información Requerida:
     % Ejemplo 1: Usar los siguientes vectores para hallar los parámetros: a * A + b * B - C = 0 -> a = 2, b = 3
          %VA = [1, 2, 3, 4];
          %VB = [4, 6, 9, 10];
          %VC = [14 22 33 38];

    % Ejemplo 2: Usar los siguientes vectores para halalr los parámetros: a * X + b * X ^ 2 + c * Y + d * Y ^ 2 - E = 0 -> a = 4, b = -5, c = 1.24, d = 3.5
          %VA = [0.928312728 0.806736479 0.706441955 0.828373787 0.919196645 0.914646477 0.354718535 0.286822233 0.297501915 0.308396155 0.866149238 ...
          %      0.604452426 0.8956388];
          %VB = VA .^2;
          %VC = [0.518822001 0.581078475 0.37366208 0.81609746 0.705031285 0.383936928 0.84160678 0.568675103 0.448519194 0.349774984 0.707877462 ...
          %      0.317667703 0.756904018];
          %VD = VC .^2;
          %VE = [0.989884524 1.875147168 1.282489346 3.225493067 2.066154907 0.467703285 4.312397254 2.572980898 2.007727649 1.619963547 2.345109244 ...
          %      1.338098672 2.515434805];

MatrizV = [VA; VB; VC; VD; VE];

Long = length(VA);
Par = size(MatrizV, 1) - 1;
Var = Par + 1;

VecValSem = "1, 1, 1, 1";

% Presentación:
     disp("% Generación de Código: Método de Newton")
     disp("% Número de Funciones: " + Long)
     disp("% Número de Parámetros: " + Par)
     disp("% Número de Variables: " + Var)
     disp(" ")

% Vectores de Valores:
     disp("% Vectores con sus valores: ")
     VecValores = "";
     for j = 1 : Var
          for i = 1 : Long
               if i ~= Long
                    VecValores = VecValores + MatrizV(j, i) + ", ";
               elseif i == Long
                    VecValores = VecValores + MatrizV(j, i);
               end
          end

          disp("L" + j + " = [" + VecValores + "];")
          VecValores = "";
     end
     disp(" ")

% Vector para Indicar Variables en las Funciones: Para expresar las variables requeridas en "@(*Variables*)", por ejemplo
     VecPar = ""; VecRai = ""; VecSem = ""; VecRaiA = ""; VecVal0 = ""; VecVal1 = ""; VecTol = "";
     for j = 1 : Par
          VecPar = VecPar + "X" + j;
          VecRai = VecRai + "R" + j;
          VecSem = VecSem + "S" + j;
          VecRaiA = VecRaiA + "RaicesA(" + j + ")";
          VecVal0 = VecVal0 + "0";
          VecVal1 = VecVal1 + "1";
          VecTol = VecTol + "Tol";
          if j ~= Par
               VecPar = VecPar + ", ";
               VecRai = VecRai + ", ";
               VecSem = VecSem + ", ";
               VecRaiA = VecRaiA + ", ";
               VecVal0 = VecVal0 + ", ";
               VecVal1 = VecVal1 + ", ";
               VecTol = VecTol + ", ";
          elseif j == Par
               VecPar = VecPar;
               VecRai = VecRai;
               VecSem = VecSem;
               VecRaiA = VecRaiA;
               VecVal0 = VecVal0;
               VecVal1 = VecVal1;
               VecTol = VecTol;
          end
     end

% Construcción de las Funciones (F) igualadas a 0
     disp("% Funciones: ")

     % Fi = X1 * VA(i) + X2 * VB(i) + ... - VC(i)
     for i = 1 : Long

          ExprFun = "F" + i + " = " + "@(" + VecPar + ") ";

          for j = 1 : Var
               if j == Var
                    ExprFun = ExprFun + "L" + j + "(" + i + ")";
               elseif j == Var - 1
                    ExprFun = ExprFun + "X" + j + " * " + "L" + j + "(" + i + ")" + " - ";
               elseif j ~= Var
                    ExprFun = ExprFun + "X" + j + " * " + "L" + j + "(" + i + ")" + " + ";
               end
          end

          disp(ExprFun + ";") % Presentación de la Ecuación
     end 
     disp(" ")

% Construcción de las derivadas (DF):
     disp("% Derivadas: ")
     disp("h = 0.0001; ")

     % DF1X1 = (F1(X1 + h, X2) - F1(X1, X2)) / h
     % DF1X2 = (F1(X1, X2 + h) - F1(X1, X2)) / h
     
     % DF2X1 = (F2(X1 + h, X2) - F2(X1, X2)) / h
     % DF2X2 = (F2(X1, X2 + h) - F2(X1, X2)) / h

     for i = 1 : Long
          for j = 1 : Par
               % Configuración de Primer Término, dependiendo de cuál será el que reciba la h / el diferencial
               for k = 1 : Par
                    if k ~= j 
                         InteriorPrimerTermino(k) = "X" + k + "";
                    elseif k == j
                         InteriorPrimerTermino(k) = "X" + k + " + h";
                    end
               end
     
               VecPrimTerm = "";
               for k = 1 : length(InteriorPrimerTermino)
                    VecPrimTerm = VecPrimTerm + InteriorPrimerTermino(k);
                    if k ~= length(InteriorPrimerTermino)
                         VecPrimTerm = VecPrimTerm + ", ";
                    elseif k == length(InteriorPrimerTermino)
                         VecPrimTerm = VecPrimTerm;
                    end
     
               end
     
               VecSegunTerm = VecPar;
     
               disp("DF" + i + "X" + j + " = " + "@(" + VecPar + ") " + "(" + ... % Presentación de la Derivada
                    "F" + i + "(" + VecPrimTerm + ")" + ... % Primer Término
                    " - " + ("F" + i + "(" + VecSegunTerm + ")") + ... % Segundo Término
                    ")" + " * (1 / h)" + ";") % Cerrar expresión y agregar cociente
          end
     
          disp(" ")
     end

% Construcción del Proceso de Iteración:
     % Configuración inicial:
          disp("% Configuración para el Ciclo: ")
          disp("[" + VecSem + "]" + " = " + "deal(" + VecValSem + "); % Semillas")
          disp("ExpTol = -3; " + "Tol = 10 ^ -abs(ExpTol); " + "VTol = [" + VecTol + "]; " + "nmax = 100;")
          disp("[" + VecRai + "]" + " = " + "deal(" + VecSem + ");")
          disp("RaicesA = " + "[" + VecRai + "];")
          disp("Error = " + "[" + VecVal1 + "];")
          disp("n = 0;")
          disp(" ") % Espacio

          disp("while max(Error) > max(VTol)")

     % Jacobiano
          disp("% Establecimiento del ciclo de iteración: ")
          disp(" ")
          disp("% Matriz de derivadas parciales evaluadas: ")
          disp("Jacob = [ ...")
     
          for i = 1 : Long
               % Filas: Función Constante, diferente Variable
               Fila = "";
          
               for j = 1 : Par
                    if j ~= Par 
                         Fila = Fila + "DF" + i + "X" + j + "(" + VecRai + ") ";
                    elseif j == Par
                         Fila = Fila + "DF" + i + "X" + j + "(" + VecRai + ") ";
                    end
               end
     
               if i ~= Long
                    Fila = Fila + ";";
               elseif i == Long
                    Fila = Fila + "...";
               end
     
               disp(Fila)
          end
          disp("]" + ";")
          disp(" ") % Espacio

    % Vector de funciones evaluadas:
          disp("% Vector de funciones evaluadas: ")
          disp("B = [ ...")

          q = 0;
          FilaFun = "";
          for i = 1: Long
               if i ~= Long
                    FilaFun = FilaFun + "F" + i + "(" + VecRai + ")" + ", ";
                    q = q + 1;
               elseif i == Long
                    FilaFun = FilaFun + "F" + i + "(" + VecRai + ")";
               end

               if i == Long
                    disp(FilaFun + "]'" + ";")
                    FilaFun = "";
                    q = 0;
               elseif q == 5
                    disp(FilaFun + " ...")
                    FilaFun = "";
                    q = 0;
               end
          end

          
          disp(" ") % Espacio
               
     % Configuración de Resolución:
          disp("% Resolución del sistema de Ecuaciones: Se utiliza la forma 'X[i + 1] ) X[i] + DeltaX' y se evalúa el error")
          disp("RaicesDelta = Jacob \ -B;")
          disp("RaicesB = RaicesA + RaicesDelta';")
          disp("Error = abs(RaicesB - RaicesA);")
          disp("RaicesA = RaicesB;")
          disp("[" + VecRai + "]" + " = " + "deal(" + VecRaiA + ");")
          disp("n = n + 1;")
          disp(" ") % Espacio
          disp("% En caso de emergencia: ")
          disp("if n == nmax")
          disp("Error = " + "[" + VecVal0 + "];")
          disp("end")
          disp(" ") % Espacio
          disp("end")
          disp(" ")

     % Salida de Respuestas:
     disp("% Parámetros Obtenidos: ")
     for j = 1 : Par
          TxTA = '"Parámetro "';
          TxTB = '" para L"';
          TxTC = '": "';

          TxTResp = ("disp(" + TxTA + " + " + j + " + " + TxTB + " + " + j + " + " + TxTC + " + " + "R" + j + ")");
          disp(TxTResp)
     end
     
