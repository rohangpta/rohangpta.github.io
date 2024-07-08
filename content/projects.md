---
title: "Projects"
draft: false
---


- [Second Brain](https://github.com/second-brain-labs/web-app): Inspired by
  tools like [Pinboard](https://pinboard.in) and the concept of Vannevar Bush's
  [Memex](https://worrydream.com/refs/Bush_1945_-_As_We_May_Think_(Life_Magazine).pdf),
  I built a tool to intelligently store, search, and interact with personal documents.

  Powered by Vespa + Mixtral-8x7b, this product autonomously did some of my
  school and personal grunt work and performed better than ChatGPT for Q/A over documents.

- [Penn Clubs](https://pennclubs.com): Penn Clubs is the official student club
  repository at Penn. While in school, I worked as a developer lead on the product, which is
  managed as part of the umbrella student club [Penn
  Labs](https://pennlabs.org). 
  
  Check us out! We build a lot of cool, open-source software for
  the Penn community and have saved the university well into the 6 figures in
  software costs.
  
- [Spruce](https://github.com/jaredasch/Spruce): A friend and I wrote a parser
  and interpreter in Haskell for a language called _Spruce_ with functional
  features (first class functions, lexically scoped closures) and low-level
  concurrency primitives (fork, wait) alongside a simple interface to support
  [transactions over memory](https://hackage.haskell.org/package/stm).
  
  This project makes it easy to write (in Spruce):
  
  ```
  let shared x : int = 0
  func f() -> void {
     for (i : int in range(3000)) {
        atomic {
            x = x + 1;
        }
     }
  }
  s1 = fork(f); s2 = fork(f);
  wait(s1); wait(s2);
  assert x == 6000
  ```
  
  and guarantee consistency in output. The STM monad is
  [beautiful](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/beautiful.pdf).

- [Distributed ML Pipeline](https://github.com/rohangpta/dist-ml-pipeline): For
  a DevOps final project, I built a distributed Machine Learning pipeline
  (training and inference) on
  Kubernetes that aims to be model-agnostic and supports MLOps best practices (Continuous Training and Continuous Monitoring).

- [CIS 1880:
  DevOps](https://cis1880.org/): I co-taught a (now discontinued) class on
  DevOps at Penn.  Born out of an older NETS major's distaste for Penn's
  relatively outdated
  cloud computing class -- NETS 212 -- this class cultivated my budding interest
  in cloud infrastructure. Unikernels anyone?
  
- [RuneScape 2D](https://github.com/rohangpta/runescape-2d): I used to play a lot of RuneScape when I was in high-school, so for a class final project I built a minimal 2D version of the game's old tutorial, mostly for nostalgia.
