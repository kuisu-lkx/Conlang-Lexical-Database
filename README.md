# Conlang Lexical Database

*A hobby project for developing constructed languages through an executable lexical database.*

## What is this?

This project explores the idea of treating a conlang's lexicon as structured data rather than as a collection of word lists or dictionary entries.

Instead of manually maintaining pronunciation, stems, paradigms and other derived information, the database stores only the essential lexical data and generates everything else from a set of linguistic rules.

The long-term goal is not to build a language processor, but to create a practical workbench for conlang development: a place where phonology, morphology and the lexicon can evolve together while remaining internally consistent.

## Why?

Conlangs evolve.

A small phonological change or a revised declension often requires updating dozens or even hundreds of lexical entries. Doing this manually is slow, error-prone and discourages experimentation.

By deriving information from a compact lexical database, the language can be refactored freely. Rules can be changed, regenerated and evaluated against the entire lexicon, making it much easier to discover patterns, inconsistencies and new ideas.

In that sense, the database becomes both a reference and a laboratory for the language.

## Current state

This is an active hobby project and very much a work in progress.

The codebase changes frequently as both the software and the conlang develop together. There is currently:

* no stable release
* no roadmap
* no feature request process
* no guarantee of backwards compatibility
* functions can only be executed with the maintenance sript:
    ```
    lua maintenance.lua print_all
    ```
* for more functions see maintenance.lua "parse command" section, the cli is still some time away
* see comment in input-example/TEST.root.lua for details on the expected directory structure

The repository mainly serves as a place to develop ideas and to document the project's evolution.

## AI-assisted development

Large parts of the implementation have been developed in collaboration with ChatGPT.

The overall project design, linguistic concepts and development direction are my own, while ChatGPT has contributed substantially to software architecture, implementation, code review, debugging and discussion of linguistic modelling.

The result is a collaborative exploration of how software engineering and linguistic analysis can support one another during conlang development.

## Inspiration

If you're building a conlang yourself and still keeping your vocabulary in text documents or spreadsheets, perhaps this idea is worth exploring.

A lexical database doesn't just store your language—it can help you understand, test and refine it.
