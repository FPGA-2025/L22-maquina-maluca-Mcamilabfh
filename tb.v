`timescale 1ns/1ps

module tb();
    reg         clk;
    reg         rst_n;
    reg         start;
    wire [3:0]  state;

    // Instância da máquina defeito → corrigida
    maquina_maluca dut (
        .clk   (clk),
        .rst_n (rst_n),
        .start (start),
        .state (state)
    );

    // — Clock 10 ns período —
    initial clk = 0;
    always  #5  clk = ~clk;

    // — Estados nomeados —
    localparam IDLE                = 4'd1;
    localparam LIGAR_MAQUINA       = 4'd2;
    localparam VERIFICAR_AGUA      = 4'd3;
    localparam ENCHER_RESERVATORIO = 4'd4;
    localparam MOER_CAFE           = 4'd5;
    localparam COLOCAR_NO_FILTRO   = 4'd6;
    localparam PASSAR_AGITADOR     = 4'd7;
    localparam TAMPEAR             = 4'd8;
    localparam REALIZAR_EXTRACAO   = 4'd9;

    // — Vetor de estados esperados —
    reg [3:0] esperado [0:9];
    integer   i;

    initial begin
        $dumpfile("saida.vcd");
        $dumpvars(0, tb);

        // 1) Reset
        rst_n = 0; start = 0; #20;
        rst_n = 1;         #20;

        // 2) Dispara a máquina
        start = 1;

        // 3) Preenche o vetor de referência
        esperado[0] = LIGAR_MAQUINA;
        esperado[1] = VERIFICAR_AGUA;
        esperado[2] = ENCHER_RESERVATORIO;
        esperado[3] = VERIFICAR_AGUA;
        esperado[4] = MOER_CAFE;
        esperado[5] = COLOCAR_NO_FILTRO;
        esperado[6] = PASSAR_AGITADOR;
        esperado[7] = TAMPEAR;
        esperado[8] = REALIZAR_EXTRACAO;
        esperado[9] = IDLE;

        // 4) A cada borda de clock, lê um estado e compara
        for (i = 0; i < 10; i = i + 1) begin
            @(posedge clk);   // nova transição acaba de acontecer
            #1;               // segura por 1 ns pra garantir update
            if (state === esperado[i])
                $display("OK   : Estado %0d correto (%0d)", i, state);
            else
                $display("ERRO : Esperado estado %0d, recebido %0d", esperado[i], state);
            // Depois de capturar o primeiro estado, desliga o start
            if (i == 0) start = 0;
        end

        $finish;
    end

endmodule
