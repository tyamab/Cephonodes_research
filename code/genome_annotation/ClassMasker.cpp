// ./a.out reference.fasta fout.txt

#include <vector>
#include <fstream>
#include <iostream>
#include <string>
#include <sstream>
#include <unordered_map>

using namespace std;

//group structure
struct group
{
	int gspos;
	int gepos;
};

//split function
vector<string> Split(const string &s, char delim)
{
	vector<string> elems;
	stringstream ss(s);
	string item;
	while (getline(ss, item, delim))
	{
		if (!item.empty())
		{
			elems.push_back(item);
		}
	}
	return elems;
}

//StoI function
int StoI(string str)
{
	int number;
	istringstream iss(str);
	iss >> number;
	return number;
}

int main(int argc, char*argv[])
{
  // get number of parameter
	if(argc != 5)
	{
		cout << "./a.out [fasta] [repeatmask.out] [fout] [Family name]" << endl;
		return 0;
	}
// reading files to sort
	ifstream ifs(argv[1]);
	if(ifs.fail())
	{
		cout << "error:fasta file not open" << endl;
		return 0;
	}
	ifstream ifs2(argv[2]);
	if(ifs2.fail())
	{
		cout << "error:repeatmask.out file not open" << endl;
		return 0;
	}
//output file
	ofstream fout(argv[3]);
	if(fout.fail())
	{
		cout << "error:fout file not open" << endl;
		return 0;
	}
//Family name
	string Family = argv[4];
	if(Family.empty())
	{
		cout << "error:Family is required" << endl;
		return 0;
	}

	string zero;


	vector<string> I;
	string lin, scf, stat;
	group groups1;
	int spos, epos;
	int count = 0;
	unordered_multimap<string, group> hash;

	while(getline(ifs2,lin) )
	{
		count++;
		if(count > 3)
		{
			I = Split(lin, ' ');
			stat = I[10];
			if(stat.find(Family) != std::string::npos)
			{
				scf = I[4];
				spos = StoI(I[5]);
				epos = StoI(I[6]);
				groups1 = {spos, epos};
				hash.insert(pair<string, group>(scf, groups1));
			}
		}
	}

	int cutfasnum, check;
	string cutfas, fasta;
	int genelength = 0;
	int maskcount = 0;

	while(getline(ifs, lin) )
	{
		string::size_type a1 = lin.find(">");
		if(a1 != string::npos)
		{
			if(fasta != zero)
			{
				auto range = hash.equal_range(scf);
				for (auto iterator = range.first; iterator != range.second; iterator++)
				{
					auto target = *iterator;
					spos = target.second.gspos;
					epos = target.second.gepos;
					for(int i = spos - 1; i < epos; i++)
					{
						if(fasta[i] != 'X')
						{
							fasta[i] = 'X';
							maskcount++;
						}
					}
				}
				check = 0;
				genelength += fasta.length();
				cutfasnum = fasta.length() / 50;
				check = fasta.length() % 50;

				for(int i = 0; i <= cutfasnum; i++)
				{
					if(i == cutfasnum && check != 0)
					{
						cutfas = fasta.substr(i*50);
						fout << cutfas << endl;
					}
					else
					{
						cutfas = fasta.substr(i*50, 50);
						fout << cutfas << endl;
					}
				}
			}


			string::size_type a2 = lin.find(" ");
			if(a2 != string::npos)
			{
				scf = lin.substr(1,a2-1);
			}
			else
			{
				scf = lin.substr(1);
			}
			fout << ">" << scf << endl;
			fasta = zero;
		}
		else
		{
			fasta += lin;
		}
	}

	auto range = hash.equal_range(scf);
	for (auto iterator = range.first; iterator != range.second; iterator++)
	{
		auto target = *iterator;
		spos = target.second.gspos;
		epos = target.second.gepos;
		for(int i = spos - 1; i < epos; i++)
		{
			if(fasta[i] != 'X')
			{
				fasta[i] = 'X';
				maskcount++;
			}
		}
	}
	check = 0;
	genelength += fasta.length();
	cutfasnum = fasta.length() / 50;
	check = fasta.length() % 50;

	for(int i = 0; i <= cutfasnum; i++)
	{
		if(i == cutfasnum && check != 0)
		{
			cutfas = fasta.substr(i*50);
			fout << cutfas << endl;
		}
		else
		{
			cutfas = fasta.substr(i*50, 50);
			fout << cutfas << endl;
		}
	}

	double rate;
	rate = 100 * (double)maskcount / (double)genelength;
	cout << "mask(bp)" << '\t' << maskcount << endl;
	cout << "genomelength(bp)" << '\t' << genelength << endl;
	cout << "maskrate(%)" << '\t' << rate << endl;
	return 0;
}
