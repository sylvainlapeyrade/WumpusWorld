using System;
using System.Linq;
using Prolog;

namespace Agent.AI
{
    public class AIProlog : AIBasic
    {
        public override void FirstTurn()
        {
            GetComponent<AgentMove>().MoveCell(); // Move to a cell
            GetComponent<AgentSense>().SenseCell(); // Sense the current cell

            // Update the knowledge base
            GameManager.Instance.GetComponent<PrologInterface>().QueryText +=
                $", assertz(location({GetComponent<Agent>().name}, [{GetComponent<Agent>().coords.x}, {GetComponent<Agent>().coords.y}]))";

            foreach (var perso in GameManager.Instance.personalities.Where(perso => GetComponent<Agent>().GetComponent(Type.GetType("Ontology." + perso))))
                GameManager.Instance.GetComponent<PrologInterface>().QueryText +=
                $", assertz(trait({GetComponent<Agent>().name}, {perso.ToString().ToLower()}))";
        }

        public override void PlayTurn()
        {
            // Query the knowledge base for agent actions
            switch (GameManager.Instance.GetComponent<PrologInterface>().QueryKb(GetComponent<Agent>().name))
            {
                case "attack" or "shoot" or "shootarrow": // Try shooting an arrow
                    GetComponent<AgentAction>().TryShootingArrow();
                    break;
                case "pickup": // Pick up gold
                    GetComponent<AgentAction>().PickUpGold();
                    break;
                case "discard": // Discard the gold (destroy the GameObject)
                    GetComponent<AgentAction>().Discard();
                    break;
                case "bumpwall": // Bump into a wall
                    GetComponent<AgentMove>().BumpWall();
                    break;
                case "moveback": // Move agent back to a previous cell
                    GetComponent<AgentMove>().MoveAgent(GetComponent<AgentMove>().MoveBack());
                    break;
                case "move": // Move to a cell
                    GetComponent<AgentMove>().MoveCell();
                    break;
            }

            // Sense the element in the current cell
            GetComponent<AgentSense>().SenseCell();
        }
    }
}