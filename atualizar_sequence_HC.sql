ALTER TABLE os DISABLE TRIGGER os_beforeupdate_consolidacao;
UPDATE os
SET cod_os_nominal = right(os.cod_os_nominal, 7)
WHERE cod_empresa_serial = 11;
ALTER TABLE os ENABLE TRIGGER os_beforeupdate_consolidacao;

CREATE OR REPLACE FUNCTION ajustar_sequence_automatica(
    p_tabela text,
    p_coluna text,
    p_ano int,
    p_cod_empresa int
)
RETURNS void
LANGUAGE plpgsql
AS $$
DECLARE
    v_sequence text;
    v_ano_2 text;
    v_min bigint;
    v_max bigint;
    v_ultimo bigint;
    v_proximo bigint;
BEGIN
    -- nome da sequence: os_2021_seq_11
    v_sequence := format('os_%s_seq_%s', p_ano, p_cod_empresa);

    -- pega os 2 últimos dígitos do ano
    v_ano_2 := right(p_ano::text, 2);

    -- faixa no padrão 7 dígitos: 21 + 00000 até 21 + 99999
    v_min := (v_ano_2 || '00000')::bigint;
    v_max := (v_ano_2 || '99999')::bigint;

    -- busca o maior código já existente para empresa/ano
    EXECUTE format(
        'SELECT max((%I)::bigint)
           FROM %I os
          WHERE %I ~ ''^[0-9]+$''
            AND (%I)::bigint BETWEEN %s AND %s
            AND os.cod_empresa_serial = %s',
        p_coluna, p_tabela, p_coluna, p_coluna, v_min, v_max, p_cod_empresa
    )
    INTO v_ultimo;

    -- define o próximo número
    IF v_ultimo IS NULL THEN
        v_proximo := v_min;
    ELSE
        v_proximo := v_ultimo + 1;
    END IF;

    IF v_proximo > v_max THEN
        RAISE EXCEPTION
            'Proximo valor (%) ultrapassa o MAXVALUE (%) da sequence %',
            v_proximo, v_max, v_sequence;
    END IF;

    RAISE NOTICE 'Sequence: %, Min: %, Max: %, Ultimo: %, Proximo: %',
        v_sequence, v_min, v_max, v_ultimo, v_proximo;

    -- 1) remove limites temporariamente para permitir reposicionamento
    EXECUTE format(
        'ALTER SEQUENCE %I NO MINVALUE NO MAXVALUE',
        v_sequence
    );

    -- 2) reposiciona a sequence para dentro da nova faixa
    EXECUTE format(
        'SELECT setval(%L, %s, false)',
        v_sequence, v_proximo
    );

    -- 3) redefine o start da sequence
    EXECUTE format(
        'ALTER SEQUENCE %I START WITH %s',
        v_sequence, v_min
    );

    -- 4) reaplica a configuração final
    EXECUTE format(
        'ALTER SEQUENCE %I MINVALUE %s MAXVALUE %s INCREMENT BY 1 CACHE 1 NO CYCLE',
        v_sequence, v_min, v_max
    );
END;
$$;

SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2021, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2022, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2023, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2024, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2025, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2026, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2027, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2028, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2029, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2030, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2031, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2032, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2033, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2034, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2035, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2036, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2037, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2038, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2039, 11);
SELECT ajustar_sequence_automatica('os', 'cod_os_nominal', 2040, 11);



