class LLModelPromptConfig {
  List<double> logits = [];
  List<int> tokens = [];
  int nPast = 0;
  int nCtx = 1024;
  int nPredict = 50;
  int topK = 10;
  double topP = 0.9;
  double temp = 1;
  int nBatch = 1;
  double repeatPenalty = 1.2;
  int repeatLastN = 10;
  double contextErase = 0.5;

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
}

 // go defaults
  //  .logits = NULL,
  //       .logits_size = 0,
  //       .tokens = NULL,
  //       .tokens_size = 0,
  //       .n_past = 0,
  //       .n_ctx = 1024,
  //       .n_predict = 50,
  //       .top_k = 10,
  //       .top_p = 0.9,
  //       .temp = 1.0,
  //       .n_batch = 1,
  //       .repeat_penalty = 1.2,
  //       .repeat_last_n = 10,
  //       .context_erase = 0.5
  