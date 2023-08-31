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
  int nPast = 0;
  int nCtx = 1024;
  int nPredict = 128;
  int topK = 40;
  double topP = 0.95;
  double temp = 0.28;
  int nBatch = 8;
  double repeatPenalty = 1.1;
  int repeatLastN = 10;
  double contextErase = 0.55;
}
