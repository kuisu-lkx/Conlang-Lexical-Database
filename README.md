# Conlang Lexical Database

*A hobby project for developing constructed languages through an executable lexical database.*

## What is this?

This project explores the idea of treating a conlang's lexicon as structured data rather than as a collection of word lists or dictionary entries.

Instead of manually maintaining pronunciation, stems, paradigms and other derived information, the database stores only the essential lexical data and generates everything else from a set of linguistic rules.

The long-term goal is not to build a language processor, but to create a practical workbench for conlang development: a place where phonology, morphology and the lexicon can evolve together while remaining internally consistent.

---

## Current capabilities

The project is able to generate large parts of a dictionary automatically from compact lexical input.

Currently implemented features include:

- structured lexical database with explicit linguistic data model
- automatic generation of:
  - contracted and expanded stems
  - phonological forms
  - IPA transcription
  - nominal declension paradigms
  - compound entries
- configurable dictionary-style terminal output
- alphabetical sorting using a custom language-specific alphabet
- sorting by arbitrary linguistic categories
- automatic categorisation based on directory structure
- metadata support (status, notes, warnings, citations, changelog)
- modular architecture separating:
  - lexical constructors
  - linguistic generators
  - rendering
  - CLI infrastructure

The project is designed around the morphology and phonology of **one specific conlang**.

It is **not** intended to become a general-purpose conlang framework or dictionary generator.

---

## Why?

Conlangs evolve.

A small phonological change or a revised declension often requires updating dozens or even hundreds of lexical entries. Doing this manually is slow, error-prone and discourages experimentation.

By deriving information from a compact lexical database, the language can be refactored freely. Rules can be changed, regenerated and evaluated against the entire lexicon, making it much easier to discover patterns, inconsistencies and new ideas.

In that sense, the database becomes both a reference and a laboratory for the language.

---

## Trying it

The repository contains a small bundled example dictionary.

After cloning the repository, simply run

```bash
lua run.lua print_all -tmc
```

to generate a formatted dictionary listing.

If a local `entries/` directory exists, it is used automatically.
Otherwise the bundled example dictionary in `demo/` is loaded.

The command line interface is still under active development and currently serves mainly as a development and testing environment.

Screenshot:

![alt text](https://github.com/kuisu-lkx/Conlang-Lexical-Database/blob/main/Screenshot.png "Screenshot")

---

## Current state

This is an active hobby project and very much a work in progress.

Both the software and the language evolve together, so the codebase changes frequently.

At the moment there is:

- no stable release
- no roadmap
- no feature request process
- no guarantee of backwards compatibility
- an evolving command-line interface
- a data model that is still refined as new linguistic features are added

The repository primarily serves as both a development environment and documentation of the project's evolution.

---

## AI-assisted development

Large parts of the implementation have been developed in collaboration with ChatGPT.

The overall project design, linguistic concepts and development direction are my own, while ChatGPT has contributed substantially to software architecture, implementation, code review, debugging and discussion of linguistic modelling.

The result is a collaborative exploration of how software engineering and linguistic analysis can support one another during conlang development.

---

## Inspiration

This repository is probably far too specialised to be useful as-is for most people.

However, individual ideas or implementation techniques may be useful to others.

If you're building a conlang yourself and still keeping your vocabulary in text documents or spreadsheets, perhaps this idea is worth exploring.

A lexical database doesn't just store your language—it can help you understand, test and refine it.

Likewise, if you're interested in linguistic software, Lua, or data-driven language design, you're welcome to browse, reuse or adapt parts of the code for your own projects.





