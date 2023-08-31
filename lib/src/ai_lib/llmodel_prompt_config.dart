class LLModelPromptConfig {
  List<double> logits = [];
  List<int> tokens = [];

  // ** go defaults
  // int nPast = 0;
  // int nCtx = 1024;
  // int nPredict = 50;
  // int topK = 10;
  // double topP = 0.9;
  // double temp = 1;
  // int nBatch = 1;
  // double repeatPenalty = 1.2;
  // int repeatLastN = 10;
  // double contextErase = 0.5;

  // ** original defaults
  // int nPast = 0;
  // int nCtx = 1024;
  // int nPredict = 128;
  // int topK = 40;
  // double topP = 0.95;
  // double temp = 0.28;
  // int nBatch = 8;
  // double repeatPenalty = 1.1;
  // int repeatLastN = 10;
  // double contextErase = 0.55;

  // ** chat app defaults
  int nPast = 0;
  int nCtx = 1024; // 512 default, more than 2048 is bad
  int nPredict = 4096; // default: 128, -1 = infinity
  int topK = 40;
  double topP = 0.4; // 0.9 is default
  double temp = 0.7; // 0.8 is default
  int nBatch = 128; // default: 512 prompt Batch Size
  double repeatPenalty = 1.18; // 1.1 is default
  int repeatLastN = 64; // repeat_penalty_tokens
  double contextErase = 0.55;
}

// notes: 
// chatlib/gpt4all/gpt4all-backend/llama.cpp-230511/examples/main/README.md

 
