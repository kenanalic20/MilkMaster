

namespace MilkMaster.Application.Exceptions
{
    public class MilkMasterException : Exception
    {
        protected MilkMasterException(string message) : base(message) { }
    }
    public class MilkMasterValidationException : MilkMasterException
    {
        public MilkMasterValidationException(string message) : base(message) { }
    }
}
