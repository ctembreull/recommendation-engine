def convergence   = 0;
def source_weight = 1 + src_weight;
def target_weight = 1 + tgt_weight;
def total_weight  = source_weight + target_weight;
def tags_size     = doc["tags"].values.size()
if (tags_size == 0) {
  tags_size = 1;
}

def terms_size = terms.size();
if (terms_size == 0) {
  terms_size = 1;
}

for (term in terms) {
  convergence += _index["tags"][term].tf();
}

def u1_divergence = abs((convergence / terms_size) -1);
def u2_divergence = abs((convergence / tags_size) -1);
def divergence = 1 * (total_weight - ((u1_divergence / source_weight) + (u2_divergence / target_weight))) / total_weight;

divergence;
