﻿using MilkMaster.Domain.Models;
using System.ComponentModel.DataAnnotations;

namespace MilkMaster.Domain.Models
{
    public class Nutritions
    {
        public int Id { get; set; }
        public int ProductId { get; set; }
        public Products Product { get; set; } = null;

        public float? Energy { get; set; }
        public float? Fat { get; set; }
        public float? Carbohydrates { get; set; }
        public float? Protein { get; set; }
        public float? Salt { get; set; }
        public float? Calcium { get; set; }

    }
}
