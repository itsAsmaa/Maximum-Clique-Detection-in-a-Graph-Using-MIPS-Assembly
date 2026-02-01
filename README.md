# Maximum Clique Detection in Graphs
## MIPS Assembly Implementation

A complete implementation of maximum clique detection algorithm in MIPS assembly language for graph analysis.

---

## 📋 Project Overview

This project implements a **brute-force maximum clique detection algorithm** using MIPS assembly language. A clique is a subset of vertices in an undirected graph where every pair of vertices is directly connected by an edge. Finding the maximum clique (the largest possible clique) is crucial in many scientific and engineering applications.

### Key Features

- ✅ **File I/O Operations**: Read graph from input file, write results to output file
- ✅ **Dynamic Graph Sizing**: Supports graphs from 2×2 to 5×5 vertices
- ✅ **Input Validation**: Comprehensive checks for valid adjacency matrices
- ✅ **Brute-Force Algorithm**: Systematic enumeration of all possible subsets
- ✅ **Error Handling**: Robust error messages for invalid inputs
- ✅ **User Interface**: Interactive prompts for file names

---

## 🎓 Academic Context

**Course:** ENCS4370 - Computer Architecture  
**Project:** Project #1 - Fall 2025/2026  
**Institution:** Department of Electrical and Computer Engineering  
**Deadline:** November 20, 2025

**Team Members:**
- Asmaa Fares (1210084)
- Aya Fares (1222654)

---

## 🔍 What is a Clique?

A **clique** in graph theory is:
- A subset of vertices where **every two vertices are adjacent** (connected by an edge)
- A complete subgraph within the larger graph
- A set where all possible edges between vertices exist

A **maximum clique** is the clique with the largest number of vertices in the graph.

### Example

```
Graph:        Clique {1, 2, 3}:
   1---2         1---2
   |\ /|          \ /
   | X |           3
   |/ \|
   3---4
```

In this graph, vertices {1, 2, 3} form a clique of size 3 because all three vertices are mutually connected.

---

## 📊 Input Format

The program reads a graph represented as an **adjacency matrix** from a text file.

### Format Specifications

```
0 1 2 3 4
0 0 1 1 0 0
1 1 0 1 1 0
2 1 1 0 1 0
3 0 1 1 0 1
4 0 0 0 1 0
```

**Structure:**
- **First line**: Vertex indices (0, 1, 2, ..., N-1)
- **Following N lines**: Row index followed by N adjacency values
  - `0` = No edge between vertices
  - `1` = Edge exists between vertices

**Requirements:**
- Matrix size: 2×2 to 5×5
- Symmetric matrix (if edge from i to j, then edge from j to i)
- Diagonal must be all zeros (no self-loops)
- Only binary values (0 or 1)

### Sample Input Files

#### 3×3 Graph (Triangle)
```
0 1 2
0 0 1 1
1 1 0 1
2 1 1 0
```
**Result:** Maximum clique size 3, vertices {0, 1, 2}

#### 5×5 Graph
```
0 1 2 3 4
0 0 1 1 0 0
1 1 0 1 1 0
2 1 1 0 1 0
3 0 1 1 0 1
4 0 0 0 1 0
```
**Result:** Maximum clique size 3, vertices {1, 2, 3}

---

## 📤 Output Format

The program writes results to a text file with one of two formats:

### When Clique is Found
```
Maximum clique size: 3
Vertices in maximum clique: 1 2 3
```

### When No Clique Exists
```
No clique detected in the graph.
```

---

## 🧮 Algorithm Explanation

### Brute-Force Approach

The algorithm uses **exhaustive enumeration** to find the maximum clique:

1. **Start with largest possible size** (N vertices)
2. **Generate all combinations** of that size
3. **Test each subset** to see if it forms a clique
4. **If found**, stop (this is the maximum)
5. **If not found**, try next smaller size
6. **Repeat** until clique found or size < 2

### Clique Verification

For each subset, check if it forms a clique:
```
For each pair of vertices (i, j) in subset:
    If adjacency_matrix[i][j] == 0:
        Not a clique
    End if
End for
Is a clique ✓
```

### Complexity Analysis

- **Time Complexity**: O(2^N × N²)
  - Generate 2^N subsets
  - Check N² edges for each subset
- **Space Complexity**: O(N²)
  - Store adjacency matrix

**Note:** Maximum clique detection is an **NP-Complete problem**, which is why we limit the graph to 5 vertices.

---

## 🚀 Running the Program

### Prerequisites

- **MIPS Simulator**: MARS (MIPS Assembler and Runtime Simulator) or SPIM
- Input file in the correct format

### Step-by-Step Instructions

#### 1. **Prepare Input File**

Create a text file (e.g., `graph_input.txt`) with your adjacency matrix:
```
0 1 2
0 0 1 1
1 1 0 1
2 1 1 0
```

#### 2. **Load Program in MARS**

1. Open MARS simulator
2. File → Open → Select `max_clique.asm`
3. Assemble the program (F3 or Run → Assemble)

#### 3. **Configure MARS Settings**

- Go to **Settings → Memory Configuration**
- Ensure **"Compact, Data at Address 0"** is selected
- Enable **"Accept file I/O"** in Settings

#### 4. **Run the Program**

1. Click **Run → Go** (F5)
2. Click in the **Run I/O window** (important!)
3. Enter input filename when prompted: `graph_input.txt`
4. Press **Enter**
5. Enter output filename: `results.txt`
6. Press **Enter**

#### 5. **View Results**

Open `results.txt` to see the detected maximum clique.

### Example Session

```
Enter input file name (press Enter after typing): graph_input.txt
Enter output file name (press Enter after typing): output.txt
Reading file...
Processing complete. Results written to output file.
-- program is finished running --
```

---

## 📁 File Structure

```
project/
├── max_clique.asm              # Main MIPS assembly program
├── README.md                   # This file
├── test_inputs/                # Sample test files
│   ├── graph_3x3_triangle.txt  # Complete graph (K3)
│   ├── graph_4x4_diamond.txt   # Diamond graph
│   ├── graph_5x5_sample.txt    # Sample 5×5 graph
│   └── graph_no_clique.txt     # Graph with no cliques
├── test_outputs/               # Expected outputs
│   ├── output_3x3.txt
│   ├── output_4x4.txt
│   └── output_5x5.txt
└── docs/
    └── ENCS4370_Project_1_Spec.pdf  # Project specification
```

---

## 🧪 Test Cases

### Test Case 1: Complete Triangle (3×3)
**Input:**
```
0 1 2
0 0 1 1
1 1 0 1
2 1 1 0
```
**Expected Output:**
```
Maximum clique size: 3
Vertices in maximum clique: 0 1 2
```

### Test Case 2: Sample 5×5 Graph
**Input:**
```
0 1 2 3 4
0 0 1 1 0 0
1 1 0 1 1 0
2 1 1 0 1 0
3 0 1 1 0 1
4 0 0 0 1 0
```
**Expected Output:**
```
Maximum clique size: 3
Vertices in maximum clique: 1 2 3
```

### Test Case 3: No Clique (Chain)
**Input:**
```
0 1 2
0 0 1 0
1 1 0 1
2 0 1 0
```
**Expected Output:**
```
No clique detected in the graph.
```

### Test Case 4: Complete Graph K4
**Input:**
```
0 1 2 3
0 0 1 1 1
1 1 0 1 1
2 1 1 0 1
3 1 1 1 0
```
**Expected Output:**
```
Maximum clique size: 4
Vertices in maximum clique: 0 1 2 3
```

---

## 🔧 Program Components

### Main Functions

| Function | Description |
|----------|-------------|
| `main` | Program entry point, orchestrates I/O and processing |
| `open_input_file` | Opens input file for reading |
| `read_graph_from_file` | Reads and parses adjacency matrix |
| `parse_adjacency_matrix` | Parses text format into matrix structure |
| `validate_adjacency_matrix` | Validates matrix symmetry and format |
| `find_maximum_clique` | Main clique detection algorithm |
| `generate_and_test_subsets` | Generates all combinations of given size |
| `generate_combinations_recursive` | Recursively builds vertex combinations |
| `is_clique` | Tests if a subset forms a clique |
| `write_results_to_file` | Writes results to output file |

### Data Structures

```assembly
.data
    graph_size:          .word 0      # Number of vertices (2-5)
    adjacency_matrix:    .space 100   # 5×5 matrix (25 integers)
    max_clique_size:     .word 0      # Size of maximum clique
    max_clique_vertices: .space 20    # Vertices in max clique
    current_subset:      .space 20    # Current subset being tested
    file_buffer:         .space 1024  # Buffer for file reading
```

---

## ⚠️ Error Handling

The program handles the following error conditions:

### 1. File Not Found
```
Error: Cannot open file. Please check the file path.
```
**Cause:** Input file doesn't exist or path is incorrect

### 2. Invalid Matrix Format
```
Error: Invalid adjacency matrix format.
Matrix must be 2x2 to 5x5, symmetric, with 0s on diagonal and only 0/1 values.
```
**Causes:**
- Matrix not symmetric (adjacency_matrix[i][j] ≠ adjacency_matrix[j][i])
- Non-zero diagonal values (self-loops)
- Values other than 0 or 1
- Matrix size not between 2×2 and 5×5

---

## 💡 Implementation Highlights

### Key Design Decisions

1. **Variable-Size Support**: Unlike typical fixed-size implementations, this program dynamically handles graphs from 2×2 to 5×5

2. **Top-Down Search**: Searches from largest possible clique size downward, ensuring the first clique found is maximum

3. **Recursive Combination Generation**: Uses recursion to systematically generate all possible vertex combinations

4. **Comprehensive Validation**: Three-stage validation:
   - Format parsing
   - Symmetry checking
   - Diagonal verification

### MIPS-Specific Considerations

- **Register Usage**: Carefully managed to avoid conflicts across function calls
- **Stack Management**: Proper saving/restoring of registers in nested functions
- **File I/O**: Uses MARS syscalls (13-16) for file operations
- **Memory Layout**: Efficient use of `.space` directives for arrays

---

## 📈 Performance Characteristics

### Execution Times (Approximate)

| Graph Size | Subsets Checked | Typical Cycles |
|-----------|----------------|----------------|
| 2×2 | 3 | ~1,000 |
| 3×3 | 7 | ~5,000 |
| 4×4 | 15 | ~20,000 |
| 5×5 | 31 | ~100,000 |

**Note:** Actual performance depends on graph structure and when maximum clique is found.

---

## 🐛 Troubleshooting

### Problem: "Error: Cannot open file"
**Solutions:**
- Ensure file exists in MARS working directory
- Use full file path if needed
- Check file permissions

### Problem: "Invalid adjacency matrix format"
**Solutions:**
- Verify matrix is symmetric
- Ensure diagonal contains only zeros
- Check all values are 0 or 1
- Confirm matrix size is 2×2 to 5×5

### Problem: Program hangs or doesn't respond
**Solutions:**
- Click in the **Run I/O window** before typing
- Ensure input file is properly formatted
- Check for infinite loops in large graphs

### Problem: No output file generated
**Solutions:**
- Check MARS file I/O settings are enabled
- Verify write permissions in output directory
- Ensure program completes successfully

---

## 📚 Educational Value

### Learning Objectives

This project demonstrates:

1. **Low-level programming** in assembly language
2. **Algorithm implementation** from pseudocode to machine code
3. **File I/O operations** at the system call level
4. **Data structure manipulation** in memory
5. **Recursion** in assembly language
6. **Combinatorial algorithms** and their complexity
7. **Graph theory** practical applications

### Concepts Covered

- MIPS instruction set architecture
- Stack frame management
- Function calling conventions
- Memory addressing modes
- Bitwise operations
- Control flow structures
- System call interface

---

## 🔬 Extensions and Improvements

### Possible Enhancements

1. **Optimization**: Implement pruning strategies to reduce search space
2. **Larger Graphs**: Support graphs beyond 5×5 with optimized algorithms
3. **Visualization**: Generate graph visualization output
4. **Multiple Cliques**: Find all maximum cliques, not just one
5. **Heuristics**: Implement approximate algorithms for better performance
6. **Statistics**: Report algorithm performance metrics

### Advanced Algorithms

For larger graphs, consider:
- **Bron-Kerbosch algorithm**: More efficient clique enumeration
- **Branch and bound**: Prune search space earlier
- **Greedy heuristics**: Fast approximate solutions

---

## 📖 References

### Graph Theory
- Introduction to Graph Theory by Douglas B. West
- Graph Theory with Applications by Bondy and Murty

### MIPS Assembly
- Computer Organization and Design (Patterson & Hennessy)
- MARS Simulator Documentation
- MIPS Assembly Language Programming by Robert Britton

### Algorithms
- Introduction to Algorithms (CLRS)
- The Algorithm Design Manual by Steven Skiena
---

## 📧 Contact

For questions or issues:
- **Asmaa Fares**: 1210084
- **Aya Fares**: 1222654

**Course Instructor:** To be confirmed  
**Department:** Electrical and Computer Engineering

---

## 📜 License

This project was developed as part of ENCS4370 coursework and is subject to academic integrity policies.

