def convergence   = 0;
def source_weight = 1 + src_weight;
def target_weight = 1 + tgt_weight;
def total_weight  = source_weight + target_weight;

for (term in terms) {
  convergence += _index["tags"][term].tf();
}

def u1_divergence = abs((convergence / terms.size()) -1);
def u2_divergence = abs((convergence / doc["tags"].values.size()) -1);
def divergence = 1 * (total_weight - ((u1_divergence / source_weight) + (u2_divergence / target_weight))) / total_weight;

divergence;
