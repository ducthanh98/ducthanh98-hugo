---
title: "Generative AI: Chunking Strategies, Prompt Engineering & AWS Bedrock"
date: 2024-02-01T10:00:00+07:00
draft: false
categories: ["AI & Data"]
tags: ["GenAI", "LLM", "RAG", "AWS Bedrock", "Prompt Engineering"]
---

Core concepts in Generative AI architectures, Retrieval-Augmented Generation (RAG) chunking strategies, Prompt Engineering techniques, and AWS Bedrock services.

---

# RAG Chunking Strategies

Chunking divides long documents into smaller segments for embedding and vector similarity search.

## 1. Fixed-Size Chunking (Standard)
- **Concept**: Chunks document into fixed token lengths (e.g. 300 - 512 tokens) with an overlap percentage (e.g. 10 - 20%).
- **Pros**: Fast, simple, predictable computation.
- **Cons**: Can cut sentences or paragraphs mid-thought, causing loss of semantic context.

## 2. Hierarchical Chunking (Parent-Child)
- **Concept**: Multi-tiered chunks where large parent documents contain multiple smaller child chunks.
- **Workflow**:
  1. Vector similarity search matches against granular **child chunks** for high precision.
  2. The larger **parent chunk** is passed to the LLM context window to provide rich surrounding context.

## 3. Semantic Chunking
- **Concept**: Uses an embedding model to evaluate semantic similarity between adjacent sentences and breaks chunks when a thematic shift occurs.
- **Key Parameters**:
  - `Maximum Tokens`: Hard ceiling per chunk.
  - `Buffer Size`: Number of surrounding sentences evaluated during embedding calculations.
  - `Breakpoint Threshold`: Percentile distance deciding when a new chunk begins.

---

# Prompt Engineering

| Technique | Description | Best For |
| :--- | :--- | :--- |
| **Zero-Shot Prompting** | Provide instruction with zero examples. Relies purely on the model's pre-trained knowledge. | Simple classification, basic summaries. |
| **Few-Shot Prompting** | Provide a few input-output demonstrations before the final query. | Formatting enforcement, nuanced domain tasks. |
| **Chain-of-Thought (CoT)** | Instruct model to think step-by-step (*"Let's think step by step"*). | Math, logic puzzles, multi-step reasoning. |

---

# AWS Bedrock & Enterprise AI Services

## AWS Bedrock Guardrails
Provides safety and governance filters for foundation model inputs and responses:
- **Content Filtering**: Filters out hate speech, insults, sexual content, and violence.
- **Topic Denylists**: Restricts conversations to defined business topics.
- **Sensitive Information (PII)**: Masks or blocks Social Security Numbers, emails, phone numbers, and credentials.
- **Contextual Grounding Check**: Detects hallucinations by validating if the model response is factually grounded in retrieved RAG context.

## Bedrock Data Automation
- Automated ingestion and extraction of structured data from multi-modal sources (PDFs, images, tables, unstructured documents).

## Amazon SageMaker Data Wrangler
- Feature engineering tool for AI/ML pipelines:
  - Import tabular and image datasets from S3, Redshift, Snowflake.
  - Visualize distributions, correlations, and missing values.
  - Transform and engineer ML features with 300+ built-in transformations without code.
