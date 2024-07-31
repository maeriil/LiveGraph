# LiveGraph

Live graph is a debugging module meant for viewing how a value changes over time. It is originally not meant to be used for Live game, however the support for this may come later in future.

Planned features include:

- [ ] A dynamic graph viewer that is able to continously increase size based on `delta time`
- [ ] Graph view should be able to properly plot the desired `y` values.
- [ ] Graph view should be able to support the following data types
  - [ ] `number` datatype
  - [ ] `Vector2` datatype (have 2 lines representing this vector)
  - [ ] `Vector3` datatype (have 3 lines representing this vector)
  - [ ] `NaN` When a `NaN` number is passed as input, we will draw a red vertical line to indicate that there are `NaN` values outputted. This helps finding out quickly that the code provided most likely has some errors
- [ ] Graph view should be able to support graphing multiple values
- [ ] Graph view should have a settings panel supporting features like:

  - [ ] Stop button: Halts the graph from graphing anymore data
  - [ ] Play button: Continues rendering the graph
  - [ ] Reset button: Clears out all the data from the graph, creating a new clean empty graph.
  - [ ] History button: Get all the plotted points from the graph thus far

- [ ] Graph view should be able to support following features
  - [ ] Window title bar to support the following operations
    - [ ] Minimize the graph view
    - [ ] Maximize the graph view
    - [ ] Delete the graph view
    - [ ] Make the graph view draggable
    - [ ] Focusing on a graph by clicking on it should make it appear in the front
  - [ ] Graph title with default value provided
  - [ ] Graph Labels with default value provided
  - [ ] Graph colours with default value provided
  - [ ] Zoom In/Out of graph: Zooming in should decrease the `x` value such that the difference between `x2-x1` is lower. Zooming out is the opposite. By default we currently have `100 pixels` represented as `1 dt unit`. When we zoom in /out, we need to most likely rerender the whole graph - [ ] Horizontal and Vertical bars in the graph to quickly figure out what the value of the current point is
  - [ ] Tooltip on the point to figure out what the current point's exact value is
  - [ ] Graph view should be performant; This means that we should only be rendering `X` amount points, where `X` is the amount of (x-coord) points we can fit in current `Zoom`. So when we zoom out of our graph, We should keep things same, except instead of using like points `1, 2, 3, 4, 5, 6, 7, 8, 9 ,10` for when our zoom level was at `1`, in our zoom level of for eg, `0.5`, we would use points like `1, 10, 20, 30, 40, 50, 60, 70 80, 90`. As we zoom in more, the more precise it should become
  - [ ] UI widgets should be created through plasma / Dear ImGui. Can be done later on
  - [ ] Add support for the following graph types (note: these will only be created after a request or popularity):
    - [ ] Bar graph
    - [ ] Line graph
    - [ ] Pi Graph
    - [ ] Statistical graph
    - [ ] Scatter graph (?)
    - [ ] Candlestick graph
    - [ ] Gauge graph
    - [ ] Control graph
    - [ ] Stacked area graph
    - [ ] Stacked bar graph
    - [ ] Multi line graph

Current tasks:

- The graph render through our UI that we create should be done below. These are just static data so
