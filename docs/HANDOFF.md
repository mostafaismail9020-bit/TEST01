# Handoff: مساعد ABAP الشخصي (ABAP Agent)

> الملف ده عشان تكمّل الشغل على اللابتوب. افتح Claude Code في فولدر الريبو وقوله:
> **"اقرأ docs/HANDOFF.md وكمّل من الخطوة الجاية"**

## الفكرة باختصار
سيرفر بتاعنا، عليه **agent** متخصص في SAP/ABAP.
- **المخ**: Claude عن طريق API (مأجّر، أذكى وأرخص في البداية).
- **الإيدين (الأدوات) والمكتب (السيرفر) والبيانات**: بتوعنا احنا.
- طبقة الموديل منفصلة، فينفع بعدين نغيّرها لموديل مفتوح (Ollama/vLLM) لو عميل طلب إن الداتا ماتطلعش برة.

## القرار اللي اتاخد
نبدأ بحاجة واحدة صغيرة ومفيدة: **مساعد ABAP**، صفحة شات بسيطة:
1. تحط كود ABAP ← يراجعه ويقول الغلط ويصلّحه.
2. تحط error أو ST22 dump ← يقول السبب والحل.
3. تسأل أي سؤال SAP ← يجاوب.

## الخطة (بالترتيب)
| # | الخطوة | الحالة |
|---|--------|--------|
| 1 | سيرفر Python (FastAPI) + agent loop + صفحة شات + Docker | ⏳ الجاية |
| 2 | ذاكرة (RAG) على ملفاتنا ودوكيومنتيشن SFS | ⏸️ |
| 3 | ربط حقيقي بـ SAP (RFC / OData) لقراءة جداول وكود | ⏸️ |
| 4 | دمجه جوه SFS كـ feature | ⏸️ |

## مواصفات الخطوة 1 (المطلوب بناؤه)
- **Backend**: Python 3.11+، FastAPI، Anthropic Python SDK.
- **Agent loop**: رسالة ← Claude ← (لو طلب أداة نشغّلها ونرجّع النتيجة) ← رد.
- **أدوات مبدئية**:
  - `read_file`: يقرأ ملف ABAP من فولدر `workspace/`.
  - `list_files`: يعرض ملفات `workspace/`.
- **System prompt**: senior SAP ABAP consultant، يرد بالعربي المصري لما المستخدم يكتب عربي، والكود يفضل إنجليزي.
- **Frontend**: صفحة HTML واحدة (شات) يقدمها نفس السيرفر.
- **إعدادات**: المفتاح في `.env` (`ANTHROPIC_API_KEY`)، والموديل في متغير (`MODEL`) عشان نغيّره بسهولة.
- **تشغيل**: `docker compose up` أو `uvicorn` مباشرة.
- **هيكل مقترح**:
  ```
  agent/
    main.py          # FastAPI + endpoints
    agent.py         # agent loop
    tools.py         # الأدوات
    prompts.py       # system prompt
    static/index.html
  workspace/         # ملفات ABAP للتجربة
  .env.example
  requirements.txt
  Dockerfile
  docker-compose.yml
  ```
- **ملف تجربة جاهز**: `ZMM_PURCHASE_REGISTER.abap` الموجود في الريبو (نحطه في `workspace/`).

## المطلوب منك قبل ما نبدأ على اللابتوب
1. **مفتاح Claude API**: من https://console.anthropic.com ← API Keys، واشحن مبلغ صغير (5$ كفاية للتجربة).
2. **على اللابتوب**: Git + Python 3.11+ (أو Docker Desktop) + Claude Code.
3. **السيرفر**: مش محتاجينه دلوقتي. هنجرّب على اللابتوب الأول، وبعدين VPS رخيص (حوالي 5$ في الشهر).

## إزاي تكمّل على اللابتوب
```bash
git clone https://github.com/mostafaismail9020-bit/TEST01.git
cd TEST01
git checkout claude/eager-cannon-wgv6qu
claude
```
وبعدين قول لـ Claude:
> اقرأ docs/HANDOFF.md وابدأ الخطوة 1

> ⚠️ ماتحطش مفتاح الـ API في الشات ولا في Git. حطه في ملف `.env` بس (وهو هيكون في `.gitignore`).
