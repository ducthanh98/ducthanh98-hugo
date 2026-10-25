

---
title: "Generative AI: Chunking Strategies & AWS Bedrock"
date: 2024-02-01T10:00:00+07:00
draft: false
categories: ["AI & Data"]
tags: ["GenAI", "LLM", "RAG", "AWS Bedrock", "Prompt Engineering"]
---

# Chunking strategy
- Standard chunking: Fixed size: Specify tokens per chunk and overlap percentage
- Default: 300tokens per chunk
- No chunk: very document is a chunk 
# Hierarchical chunking
- Nested parent/child chunks
- Initial search hits the child chunk, and then we search back to parent chunk
# Semantic chunking
- Hits a foundation model to break up chunks based on semantic ontent and not just things like sentences or a fixed chunk 
- Speifiy 
    + maximum tokens per chunk
    + Buffer size: number of surrounding sentences per sentence to consider when embeddings
    + Too large = too noise, too small = missing important context
- Breakpoint:
    + How semantically chunk must be
    + Too big: each chunk have a clearly context, number of chunk will be lower and size of each chunk will become bigger
# AWS Bedrock Guardrail
- contet filtẻing for prompts and responses
- works with text foundation models
- word filtering
- topic filtering
- profanities
- PII removal(masking)
- contextual grounding check: prevent halu, measure grounding
- configure blocked messsage erssponse
# Prompt
## Type of prompt
- Zero shot: No example given, relies only on large models 
- Few shot: Provide some example, 
- Chain of thought(COT)

# Bedrock Data Automation
- Extract structured data from pretty much anything
- 
# SageMaker  Data Wrangler
- imoprt daa
- visualize data
- transform data
-  