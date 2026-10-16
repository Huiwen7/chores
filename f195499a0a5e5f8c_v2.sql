-- ============================================================================
-- 数据质量缺失率核查 SQL 脚本（完整版）
-- 覆盖指标：
--   一、妇幼保健：建档日期
--   二、预防接种：疫苗名称、疫苗厂商
--   三、电子病历：检查所见描述
--   四、死亡登记：直接死因
-- 整理日期：2026-10-16
-- ============================================================================
--
-- 【使用前必读】
-- 1. 本文件中所有 `【xxx字段】`（如 `【建档日期字段】`、`【疫苗名称字段】`、
--    `【疫苗厂商字段】`、`【检查所见描述字段】`、`【直接死因字段】`）都是占位符，
--    不是实际字段名。必须先在远程数据库中核对字段结构，确认实际字段名后，
--    再将占位符全局替换为真实字段名，才能执行缺失率统计语句。
-- 2. 不要用"数据表逻辑名称"（如"孕卡建册""医学检查报告"）直接当作字段名使用。
-- 3. 儿童接种记录（ETJZXX_2 / ETYZXX_2 / ETJBXX_2）不能代表全人群预防接种记录；
--    70岁以上老年人流感疫苗接种表仅覆盖特定年龄与特定疫苗；成人体检接种史
--    （TJYFJZS_1）也不一定是完整接种明细。不要把上述几张表简单拼接后就称为
--    "全人群接种数据"；如需全人群口径，应先向数据库管理员确认是否存在统一的
--    预防接种明细表或全人群接种记录视图。
-- 4. 同一指标在多张表中的缺失率应分别报告，不要预先合并。若后续需要计算合并
--    缺失率，必须先明确：记录如何关联、如何去重、以什么人群作为分母。
-- 5. 若某张表提示无权限，先记录下来，不要直接换成逻辑名称相似但未授权的表。
-- 6. 建议执行顺序：
--      第一步：第五部分 字段核对（DESCRIBE / SELECT * 样例）
--      第二步：根据真实字段名替换各节 SQL 中的 `【...】` 占位符
--      第三步：执行第一~第四部分的缺失率统计
-- 7. 文本字段的缺失口径：默认只统计 NULL；若数据质量要求把空字符串也计入缺失，
--    请使用第三、四部分中标注"包含 NULL 和空字符串"的版本。
--    日期、数值等非文本字段按 NULL 判断即可。
-- 8. 部分数据库方言不支持 `CAST(... AS STRING)`，如执行报错，请先运行只判断
--    NULL 的版本，再按实际方言调整（如 MySQL 可用 CHAR/VARCHAR）。
-- 9. 本文件为 UTF-8 编码，如客户端中文注释乱码，请将客户端连接字符集设为
--    utf8mb4 后再执行。
-- ============================================================================


-- ============================================================================
-- 一、妇幼保健：建档日期
-- 优先检查孕卡建册、妇幼专项个人基本信息、个人健康档案等相关表。
--
-- 相关表清单：
--   优先级 | 授权表名                  | 数据表逻辑名             | 需要核对的字段
--   1      | YKJC_1                    | 孕卡建册                 | 建档日期
--   2      | FB_YCF_YKJC_SNCDM_V       | 孕卡建册                 | 建档日期
--   3      | FYXX_1                    | 妇幼专项个人基本信息       | 建档日期或相关日期
--   4      | JDXX_1                    | 健康档案个人基本信息       | 建档日期或建档时间
--   5      | DA_GR_HXDA_SNCDM_V        | 个人档案（含儿童和孕产妇） | 建档日期或建档时间
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 1.1 查看字段和样例（先执行，确认实际字段名）
-- ---------------------------------------------------------------------------

-- 1. 孕卡建册
SELECT *
FROM YKJC_1
LIMIT 10;

-- 2. 孕卡建册视图
SELECT *
FROM FB_YCF_YKJC_SNCDM_V
LIMIT 10;

-- 3. 妇幼专项个人基本信息
SELECT *
FROM FYXX_1
LIMIT 10;

-- 4. 健康档案个人基本信息
SELECT *
FROM JDXX_1
LIMIT 10;

-- 5. 个人档案视图
SELECT *
FROM DA_GR_HXDA_SNCDM_V
LIMIT 10;

-- ---------------------------------------------------------------------------
-- 1.2 统计建档日期缺失率
-- 确认实际字段名后，将 `【建档日期字段】` 替换为真实字段名。每张表单独运行。
-- ---------------------------------------------------------------------------

-- 1. 孕卡建册：建档日期缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【建档日期字段】`) AS filled_count,
    SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM YKJC_1;

-- 2. 孕卡建册视图：建档日期缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【建档日期字段】`) AS filled_count,
    SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM FB_YCF_YKJC_SNCDM_V;

-- 3. 妇幼专项个人基本信息：建档日期缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【建档日期字段】`) AS filled_count,
    SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM FYXX_1;

-- 4. 健康档案个人基本信息：建档日期缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【建档日期字段】`) AS filled_count,
    SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM JDXX_1;

-- 5. 个人档案视图：建档日期缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【建档日期字段】`) AS filled_count,
    SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【建档日期字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM DA_GR_HXDA_SNCDM_V;

-- 注意：同一指标在多张表中的缺失率应分别报告。若后续需要计算合并后的缺失率，
-- 还要先明确记录如何关联、去重，以及以什么人群作为分母。


-- ============================================================================
-- 二、预防接种：疫苗名称、疫苗厂商
-- 特别注意：目标是全人群预防接种记录，不能只查儿童接种表或70岁以上流感疫苗表。
-- 根据现有授权表清单，暂时没有明确标注为全人群通用接种明细的表，
-- 因此先查询所有相关候选表，确认它们的覆盖人群和字段。
--
-- 相关表清单：
--   优先级 | 授权表名                                    | 数据表逻辑名                 | 适用范围说明
--   1      | ETJZXX_2                                    | 儿童接种信息                 | 儿童接种记录，不能代表全人群
--   2      | ETYZXX_2                                    | 儿童预种信息                 | 儿童预种相关记录
--   3      | TJYFJZS_1                                   | 成人体检非免疫规划预防接种史   | 成人体检中登记的接种史，不一定是完整接种明细
--   4      | JZDX70_INFO_2020_REW_LG_70_view_1852_3      | 70岁以上老年人流感疫苗接种    | 仅特定年龄及疫苗
--   5      | ETJBXX_2                                    | 儿童基本信息                 | 可辅助确认儿童接种表的关联对象，不是接种明细表
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 2.1 查看字段和样例（先执行，确认每张表是否有疫苗名称/厂商字段及覆盖人群）
-- ---------------------------------------------------------------------------

-- 1. 儿童接种信息
SELECT *
FROM ETJZXX_2
LIMIT 10;

-- 2. 儿童预种信息
SELECT *
FROM ETYZXX_2
LIMIT 10;

-- 3. 成人健康体检非免疫规划预防接种史
SELECT *
FROM TJYFJZS_1
LIMIT 10;

-- 4. 70岁以上老年人流感疫苗接种
SELECT *
FROM JZDX70_INFO_2020_REW_LG_70_view_1852_3
LIMIT 10;

-- 5. 儿童基本信息（辅助核对关联字段）
SELECT *
FROM ETJBXX_2
LIMIT 10;

-- ---------------------------------------------------------------------------
-- 2.2 统计疫苗名称缺失率
-- 先确认每张表是否有疫苗名称字段，再分别运行对应语句。
-- ---------------------------------------------------------------------------

-- 1. 儿童接种信息：疫苗名称缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗名称字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM ETJZXX_2;

-- 2. 儿童预种信息：疫苗名称缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗名称字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM ETYZXX_2;

-- 3. 成人健康体检非免疫规划预防接种史：疫苗名称缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗名称字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM TJYFJZS_1;

-- 4. 70岁以上老年人流感疫苗接种：疫苗名称缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗名称字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗名称字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM JZDX70_INFO_2020_REW_LG_70_view_1852_3;

-- ---------------------------------------------------------------------------
-- 2.3 统计疫苗厂商缺失率
-- 先确认每张表是否有疫苗厂商字段，再分别运行对应语句。
-- ---------------------------------------------------------------------------

-- 1. 儿童接种信息：疫苗厂商缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗厂商字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM ETJZXX_2;

-- 2. 儿童预种信息：疫苗厂商缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗厂商字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM ETYZXX_2;

-- 3. 成人健康体检非免疫规划预防接种史：疫苗厂商缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗厂商字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM TJYFJZS_1;

-- 4. 70岁以上老年人流感疫苗接种：疫苗厂商缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【疫苗厂商字段】`) AS filled_count,
    SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【疫苗厂商字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM JZDX70_INFO_2020_REW_LG_70_view_1852_3;

-- 后续需要补查的关键点：
-- 如果以上表都不能覆盖全人群，应向数据库管理员查询是否存在统一的预防接种明细表、
-- 全人群接种记录视图，或成人/儿童之外的其他接种数据源。
-- 不要把上述几张表的记录简单拼接后就称为"全人群接种数据"。


-- ============================================================================
-- 三、电子病历：检查所见描述
-- 优先查询医学检查报告，其次查询门诊病历。
-- 检查所见描述通常更可能出现在检查报告类数据中，但具体字段名仍需通过样例确认。
--
-- 相关表清单：
--   优先级 | 授权表名   | 数据表逻辑名 | 需要核对的字段
--   1      | YXJCBG_1   | 医学检查报告 | 检查所见描述
--   2      | MZBL_1     | 门诊病历     | 检查结果、检查所见或相关文本字段
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 3.1 查看字段和样例（先执行，确认实际字段名）
-- ---------------------------------------------------------------------------

-- 1. 医学检查报告
SELECT *
FROM YXJCBG_1
LIMIT 10;

-- 2. 门诊病历
SELECT *
FROM MZBL_1
LIMIT 10;

-- ---------------------------------------------------------------------------
-- 3.2 统计检查所见描述缺失率
-- ---------------------------------------------------------------------------

-- 1. 医学检查报告：检查所见描述缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【检查所见描述字段】`) AS filled_count,
    SUM(CASE WHEN `【检查所见描述字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【检查所见描述字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM YXJCBG_1;

-- 2. 门诊病历：检查相关描述缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【检查所见描述字段】`) AS filled_count,
    SUM(CASE WHEN `【检查所见描述字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【检查所见描述字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM MZBL_1;

-- 如果该字段是文本类型，建议另外检查空字符串是否被当作缺失值。
-- 部分数据库中，NULL 和空字符串是不同的，可用下面版本把两者都纳入缺失：

-- 医学检查报告：同时统计 NULL 和空字符串
SELECT
    COUNT(*) AS total_count,
    SUM(
        CASE
            WHEN `【检查所见描述字段】` IS NOT NULL
             AND TRIM(CAST(`【检查所见描述字段】` AS STRING)) <> ''
            THEN 1 ELSE 0
        END
    ) AS filled_count,
    SUM(
        CASE
            WHEN `【检查所见描述字段】` IS NULL
              OR TRIM(CAST(`【检查所见描述字段】` AS STRING)) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_count,
    ROUND(
        SUM(
            CASE
                WHEN `【检查所见描述字段】` IS NULL
                  OR TRIM(CAST(`【检查所见描述字段】` AS STRING)) = ''
                THEN 1.0 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM YXJCBG_1;

-- 如果远程环境不支持 STRING 类型转换写法，可先运行前面只判断 NULL 的版本，
-- 再根据系统使用的 SQL 方言调整。


-- ============================================================================
-- 四、死亡登记：直接死因
-- 需要同时检查死因记录和外部导入死亡报卡信息。
-- 两张表可能来自不同的数据采集或入库流程，分别统计，不能预先假定它们完全一致。
--
-- 相关表清单：
--   优先级 | 授权表名   | 数据表逻辑名         | 需要核对的字段
--   1      | SYJL_1     | 死因记录             | 直接死因
--   2      | SWBK_3     | 外部导入死亡报卡信息 | 直接死因或死因描述
-- ============================================================================

-- ---------------------------------------------------------------------------
-- 4.1 查看字段和样例（先执行，确认实际字段名）
-- ---------------------------------------------------------------------------

-- 1. 死因记录
SELECT *
FROM SYJL_1
LIMIT 10;

-- 2. 外部导入死亡报卡信息
SELECT *
FROM SWBK_3
LIMIT 10;

-- ---------------------------------------------------------------------------
-- 4.2 统计直接死因缺失率
-- ---------------------------------------------------------------------------

-- 1. 死因记录：直接死因缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【直接死因字段】`) AS filled_count,
    SUM(CASE WHEN `【直接死因字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【直接死因字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM SYJL_1;

-- 2. 外部导入死亡报卡信息：直接死因缺失率
SELECT
    COUNT(*) AS total_count,
    COUNT(`【直接死因字段】`) AS filled_count,
    SUM(CASE WHEN `【直接死因字段】` IS NULL THEN 1 ELSE 0 END) AS null_count,
    ROUND(
        SUM(CASE WHEN `【直接死因字段】` IS NULL THEN 1.0 ELSE 0 END)
        / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM SWBK_3;

-- 如果直接死因字段是文本字段，也可以用下面的版本，把 NULL 和空字符串都纳入缺失：

-- 死因记录：直接死因缺失率（包含 NULL 和空字符串）
SELECT
    COUNT(*) AS total_count,
    SUM(
        CASE
            WHEN `【直接死因字段】` IS NOT NULL
             AND TRIM(CAST(`【直接死因字段】` AS STRING)) <> ''
            THEN 1 ELSE 0
        END
    ) AS filled_count,
    SUM(
        CASE
            WHEN `【直接死因字段】` IS NULL
              OR TRIM(CAST(`【直接死因字段】` AS STRING)) = ''
            THEN 1 ELSE 0
        END
    ) AS missing_count,
    ROUND(
        SUM(
            CASE
                WHEN `【直接死因字段】` IS NULL
                  OR TRIM(CAST(`【直接死因字段】` AS STRING)) = ''
                THEN 1.0 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0) * 100,
        2
    ) AS missing_rate_pct
FROM SYJL_1;


-- ============================================================================
-- 五、建议先统一执行的字段核对语句
-- 如果数据库支持 DESCRIBE，先用下面这组语句查看字段结构，
-- 比直接猜字段名更稳妥。如果不支持或无权限，逐张运行各部分对应的
-- SELECT * FROM 授权表名 LIMIT 10;
-- ============================================================================

-- 妇幼保健：建档日期相关表
DESCRIBE YKJC_1;
DESCRIBE FB_YCF_YKJC_SNCDM_V;
DESCRIBE FYXX_1;
DESCRIBE JDXX_1;
DESCRIBE DA_GR_HXDA_SNCDM_V;

-- 预防接种相关表
DESCRIBE ETJZXX_2;
DESCRIBE ETYZXX_2;
DESCRIBE TJYFJZS_1;
DESCRIBE JZDX70_INFO_2020_REW_LG_70_view_1852_3;
DESCRIBE ETJBXX_2;

-- 电子病历相关表
DESCRIBE YXJCBG_1;
DESCRIBE MZBL_1;

-- 死亡登记相关表
DESCRIBE SYJL_1;
DESCRIBE SWBK_3;


-- ============================================================================
-- 六、缺失率统计口径
-- 所有缺失率查询统一采用以下计算逻辑：
--   缺失率 = 缺失记录数 / 总记录数 × 100%
--   total_count      ：该表总记录数
--   filled_count     ：目标字段非空的记录数
--   null_count /
--   missing_count    ：目标字段缺失记录数
--   missing_rate_pct ：缺失率，单位为百分比
-- 注意两点：
--   1. 语句中的 `【建档日期字段】`、`【疫苗名称字段】`、`【疫苗厂商字段】`、
--      `【检查所见描述字段】`、`【直接死因字段】` 都是待替换的占位符，
--      不是实际字段名。
--   2. 如果要统计的是数据质量表中的"缺失率"，建议同时统计 NULL 和空字符串；
--      如果字段是日期、数值等类型，则先按字段类型选择合适的判断方式。
-- ============================================================================


-- ============================================================================
-- 附录（可选）：DESCRIBE 不支持或无权限时，用 information_schema 核对字段
-- 以下为 MySQL/MariaDB 风格；其他数据库请按方言调整（如 PostgreSQL 用
-- information_schema.columns + current_schema()，SQL Server 用
-- sys.columns + sys.tables）。
-- ============================================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    ORDINAL_POSITION
FROM information_schema.COLUMNS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME IN (
    'YKJC_1',
    'FB_YCF_YKJC_SNCDM_V',
    'FYXX_1',
    'JDXX_1',
    'DA_GR_HXDA_SNCDM_V',
    'ETJZXX_2',
    'ETYZXX_2',
    'TJYFJZS_1',
    'JZDX70_INFO_2020_REW_LG_70_view_1852_3',
    'ETJBXX_2',
    'YXJCBG_1',
    'MZBL_1',
    'SYJL_1',
    'SWBK_3'
  )
ORDER BY TABLE_NAME, ORDINAL_POSITION;

-- ============================================================================
-- 文件结束
-- ============================================================================
