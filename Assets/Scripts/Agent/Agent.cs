using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Serialization;

namespace Agent
{
    public class Agent : MonoBehaviour
    {
        public Vector2Int startCoord;
        public Vector2Int coords;
        public int nbGold;
        public int nbArrow;

        public GameObject prefabAgentWorld;
        public GameObject prefabGoldAgent;
        public GameObject prefabGoldMap;

        public readonly Stack<Vector2Int> PastMovements = new();

        [SerializeField] public int intelligence = 3;
        [SerializeField] public int strength = 5;
        [SerializeField] public int dexterity = 7;
        [SerializeField] public List<string> personalities;

        private AgentMove _agentMove;
        private AgentSense _agentSense;
        private AgentAction _agentAction;
        [FormerlySerializedAs("ai")] public AgentAI agentAI;

        public void Init(int agentId, Vector2Int newCoord, int nbTotalWumpus)
        {
            name = $"agent{agentId}";
            tag = "human";
            startCoord = newCoord;
            coords = startCoord;
            nbArrow = nbTotalWumpus;
            PastMovements.Push(coords);
            transform.position = GridManager.GetAgentMapOffset(newCoord);

            prefabAgentWorld = Instantiate(Resources.Load("human"), transform) as GameObject;
            if (prefabAgentWorld is null) return;
            prefabAgentWorld.tag = tag;
            prefabAgentWorld.name = name;
            prefabAgentWorld.transform.position = GridManager.GetWorldMapOffset(newCoord);

            _agentMove = gameObject.AddComponent<AgentMove>();
            _agentSense = gameObject.AddComponent<AgentSense>();
            _agentAction = gameObject.AddComponent<AgentAction>();
            agentAI = gameObject.AddComponent<AgentAI>();
        }

        public void MoveCell()
        {
            if (Input.GetKeyDown("right"))
                _agentMove.Move(new Vector2Int(coords.x + 1, coords.y));
            else if (Input.GetKeyDown("left"))
                _agentMove.Move(new Vector2Int(coords.x - 1, coords.y));
            else if (Input.GetKeyDown("up"))
                _agentMove.Move(new Vector2Int(coords.x, coords.y + 1));
            else if (Input.GetKeyDown("down"))
                _agentMove.Move(new Vector2Int(coords.x, coords.y - 1));
            else if (Input.GetKeyDown("space") || GameManager.Instance.isModeAuto) // IA
                _agentMove.Move(_agentMove.SelectNextMove());
            else if (Input.GetKeyDown("return")) // IA Random
                _agentMove.Move(_agentMove.SelectRandomMove());
        }

        public void SenseCell()
        {
            if (startCoord == coords && nbGold == 1)
                GameManager.Instance.SetGameOver($"{name} Won!", false);

            foreach (string element in GameManager.Instance.Map[coords.x, coords.y]
                         .Except(GameManager.Instance.AgentsMap[coords.x, coords.y]).Select(x => x.tag))
            {
                GridManager.AddToGrids(coords, element);
            }

            if (GameManager.Instance.Map[coords.x, coords.y].Exists(e => e.tag is "pit" or "wumpus"))
                GameManager.Instance.SetGameOver($"{name} Lost!", false);

            _agentSense.MakeInferences();
        }

        public void ActionCell()
        {
            // Bump Wall
            if (GameManager.Instance.AgentsMap[coords.x, coords.y].Exists(e => e.tag is "wall"))
                _agentMove.BumpWall();

            // PickUp Gold
            if (GameManager.Instance.AgentsMap[coords.x, coords.y].Exists(e => e.tag is "gold"))
                _agentAction.PickUpGold();

            // Shoot Arrow
            if (nbArrow > 0)
                _agentAction.TryShootingArrow();
        }
    }
}