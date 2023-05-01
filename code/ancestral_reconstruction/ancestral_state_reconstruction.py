from Bio import Phylo
import argparse

# 形質情報を読み込む (csv形式)
def read_traits(trait_str):
    traits = {}
    for line in trait_str.strip().split('\n'):
        name, trait = line.strip().split(',')
        traits[name] = str(trait)
    return traits

# listsをsetに変換する
def flatten_list(lst):
    # 空のセットを作成する
    s = set()
    # lstがstrだったら、そのまま出力
    if type(lst) == str:
        s.add(lst)
    else: 
        # リストを走査する
        for item in lst:
            # itemがリスト型である場合、再帰的にflatten_listを呼び出す
            if isinstance(item, list):
                s |= flatten_list(item)
            # itemがリスト型でない場合、sに要素を追加する
            else:
                s.add(item)
        
    # セットを返す
    return s

# 祖先形質を推定する関数を定義する
def reconstruct_ancestral_traits(tree, trait_dict):
    # treeのノードに識別子を付与
    for cnt, node in enumerate(tree.get_nonterminals()):
        if node.name is None:
            node.name = f"N{cnt}"

    # ルートノードを取得する
    root = tree.clade
    
    # 再帰的に子孫ノードから祖先ノードへたどり、形質を推定する関数を定義する
    def rec_ancestral_traits(clade):
        # 葉ノードの場合は、その形質を返す
        if clade.is_terminal():
            return trait_dict[clade.name]

        # 子孫ノードの形質を取得する
        child_traits = [rec_ancestral_traits(child) for child in clade.clades]

        # ノードの形質を推定する (子形質の集合としてまずは捉える)
        node_traits = child_traits

        # 推定された形質を形質辞書に登録する
        trait_dict[clade.name] = node_traits

        return node_traits

    # ルートノードから推定を開始する
    rec_ancestral_traits(root)

    # 形質辞書を返す
    return trait_dict

# 最小値関数をカウントする関数
def count_changes(tree, traits_set):
    changes = {}
    for trait in traits_set:
        change = 0
        for child in tree.find_clades():
            if trait in child.trait:
                continue
            else:
                if child.is_terminal():
                    change += 1
                    continue
                else:
                    child_count_dict = count_changes(child, child.trait)
                    child_min_change = min(child_count_dict, key=child_count_dict.get)
                    change += 1 + child_count_dict[child_min_change]
                    break
        changes[trait] = change
    return (changes)

def main():
    parser = argparse.ArgumentParser(description='Trait reconstruction using parsimony')
    parser.add_argument('newick', type=str, help='Input newick file name')
    parser.add_argument('traits', type=str, help='Input traits file name')
    args = parser.parse_args()

    tree = Phylo.read(args.newick, 'newick')
    
    with open(args.traits, 'r') as f:
        trait_dicts = {}
        for line in f:
            node, trait = line.rstrip().split(",")
            trait_dicts[node] = trait

    # 祖先形質を推定する
    reconstruct_ancestral_traits(tree, trait_dicts)

    # 結果を出力する
    for clade in tree.find_clades():
        clade.trait = flatten_list(trait_dicts[clade.name]) 
    root_clade = tree.clade
    calc_results = count_changes(tree, root_clade.trait)
    
    print("#_of_chromosomes", "min_changes")
    for key, value in calc_results.items():
        print(key, value)
    
    print("\nancestral chromosome number:", min(calc_results, key=calc_results.get))

if __name__ == "__main__":
    main()
