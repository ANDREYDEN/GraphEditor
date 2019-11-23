# GraphEditor
A graph editor in [Processing](https://processing.org/) with some visual algorithms and physical movement (attraction/repulsion).

## Example

![example](img/example.png)

## Download Instructions

All the different releases can be found in the `./releases/<OS>` folder. 

## Functionality

1. **Add a new node**: right-click on an empty space.
2. **Select/Deselect nodes**: left-click on the desired node. A selected node is always circled red.
3. **Connect nodes**:
  - select the first node
  - left-click the second node
4. **Delete a node**: 
  - select the desired node
  - hit the `del` key
5. **Delete an edge**: left-click on the edge nodes. Multi edges are not yet supported.
6. **Show Eulerian path animation**: hit the `e` key (if there is no Eulerian path, the screen will flash red). You can read more about the Eulerian path [here](https://en.wikipedia.org/wiki/Eulerian_path).
7. **Toggle physics**: press the `Physics` button.

Note: Look out for the active node in order to prevent connecting something accidentally.

## Inspiration

Inspired by CSAcademy's [graph editor](https://csacademy.com/app/graph_editor/).
