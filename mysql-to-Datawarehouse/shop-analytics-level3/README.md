# Shop Analytics Level 3 - BigQuery Data Warehouse Project

## Overview

Questo progetto implementa una pipeline di data warehouse su Google BigQuery con architettura a layer:

**MySQL source -> BigQuery raw -> BigQuery staging -> BigQuery marts -> analytics queries**

L'obiettivo è passare da un caricamento manuale a una struttura più vicina a un progetto Data Engineer reale, con ingestion automatizzata in Python e separazione chiara tra landing, preparazione e modello analitico finale.

---

## Architettura

### Google Cloud Project
- **Project name**: `Shop Analytics Level 3`
- **Project ID**: `shop-analytics-level-3`

### BigQuery datasets
- `raw`
- `staging`
- `marts`

### Layer logic

#### 1. Raw
Layer di landing dei dati sorgente, caricati da MySQL verso BigQuery.

Tabelle raw:
- `raw_categories`
- `raw_customers`
- `raw_customers_addresses`
- `raw_order_items`
- `raw_orders`
- `raw_payments`
- `raw_products`

#### 2. Staging
Layer intermedio per pulizia, rinomina logica e preparazione del modello analitico.

Viste staging:
- `stg_categories`
- `stg_customers`
- `stg_customer_addresses`
- `stg_order_items`
- `stg_orders`
- `stg_payments`
- `stg_products`

#### 3. Marts
Layer finale per analytics e reporting.

Tabelle marts:
- `dim_customers`
- `dim_products`
- `dim_dates`
- `fact_order_items`

---

## Passaggi completati

### 1. Creazione progetto Google Cloud
È stato creato un progetto dedicato su Google Cloud per il data warehouse.

### 2. Creazione dataset BigQuery
Sono stati creati i dataset:
- `raw`
- `staging`
- `marts`

### 3. Caricamento iniziale tabelle raw
Le tabelle sorgenti sono state caricate nel dataset `raw` e validate con query di conteggio.

Conteggi principali validati:
- `raw_categories` = 4
- `raw_customers` = 7
- `raw_customers_addresses` = 10
- `raw_order_items` = 12
- `raw_orders` = 6
- `raw_payments` = 6
- `raw_products` = 12

### 4. Creazione viste di staging
Sono state create viste BigQuery nel dataset `staging` sopra le tabelle raw.

### 5. Creazione tabelle mart
Sono state costruite le tabelle finali:
- `dim_customers`
- `dim_products`
- `dim_dates`
- `fact_order_items`

### 6. Validazione analitica
È stata eseguita una query di business sul revenue giornaliero dalla fact table.

Esempio:

```sql
SELECT
  order_date,
  SUM(line_total) AS daily_revenue
FROM `shop-analytics-level-3.marts.fact_order_items`
GROUP BY order_date
ORDER BY order_date;
```

### 7. Automazione ingestion con Python
È stato implementato uno script Python per il caricamento automatico full refresh da MySQL a BigQuery `raw`.

Flusso automatizzato:

**MySQL `source_shop` -> Python ingestion -> BigQuery `raw`**

Caratteristiche della prima versione automatizzata:
- lettura configurazione da `.env`
- connessione MySQL via SQLAlchemy + PyMySQL
- connessione BigQuery via service account JSON
- caricamento con `WRITE_TRUNCATE`
- logging su console e su file
- gestione errori per singola tabella
- riepilogo finale del run

---

## Risultato ultimo run ingestion

Ultimo run completato con successo:
- **7 tabelle processate**
- **7 tabelle riuscite**
- **0 tabelle fallite**
- **57 righe caricate**
- **durata totale**: circa 26.91 secondi

Dettaglio:
- `categories -> raw_categories` = 4 righe
- `customers -> raw_customers` = 7 righe
- `customers_addresses -> raw_customers_addresses` = 10 righe
- `order_items -> raw_order_items` = 12 righe
- `orders -> raw_orders` = 6 righe
- `payments -> raw_payments` = 6 righe
- `products -> raw_products` = 12 righe

---

## Struttura repository suggerita

```text
shop-analytics-level3/
├── README.md
├── requirements.txt
├── main_ingest.py
├── logs/
│   └── ingestion.log
├── sql/
│   ├── staging/
│   └── marts/
└── docs/
```

---

## File da escludere dal repository

Nel `.gitignore` conviene mettere almeno:

```gitignore
.env
*.json
logs/
__pycache__/
*.pyc
```

---

## Prossimi passi

1. Portare `staging` e `marts` in **dbt**
2. Aggiungere test base sui modelli
3. Rendere il progetto completamente ripetibile
4. Eventualmente introdurre una logica incrementale in futuro

---

## Stato attuale

Il progetto ha già completato con successo:

**MySQL -> Python ingestion -> BigQuery raw -> BigQuery staging -> BigQuery marts -> query analytics**

La parte successiva è industrializzare la trasformazione con **dbt**.
